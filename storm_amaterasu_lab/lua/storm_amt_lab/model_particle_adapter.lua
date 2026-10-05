-- File-driven model particles: clump resources (nuccChunkClump) and animated
-- resources (nuccChunkAnm). Produces matrices and material instances only;
-- drawing is the player's job. package is a storm_import.py data package.
local P={}
function P.new(package,modules,options)
    local f=options.float32
    local out={modules=modules,updates=0,compiled={}}
    -- nuccChunkMaterial of the package by name: an animated material instance
    -- starts as a copy of its fields (constructor 0x1412f5920).
    local materials={}
    for _,model in pairs(package.models) do for _,material in ipairs(model.materials) do materials[material.name]=material end end
    -- Rest pose of the clump of a skinned model: local matrices (nuccCoord
    -- constructor 0x1412892a0), their products down the hierarchy and the
    -- inverses of those. A NUD bone index is a coordinate index of that clump.
    local function skeletonOf(model)
        local s=model.skeleton
        if s and not s.restInverse then
            local S=assert(modules.skinning,'skinning module required for a skinned model')
            s.restLocal,s.restWorld,s.restInverse={},{},{}
            for i,v in ipairs(s.rest) do
                local localMatrix=modules.matrix.node({v[1],v[2],v[3]},{v[4],v[5],v[6]},{v[7],v[8],v[9]},f,options.sinf,options.cosf)
                local parent=s.parents[i]
                s.restLocal[i]=localMatrix
                s.restWorld[i]=parent<0 and localMatrix or modules.matrix.world(s.restWorld[parent+1],localMatrix,f)
                s.restInverse[i]=assert(S.inverse(s.restWorld[i]),'A coordinate of a skinned model has a flat rest transform')
            end
        end
        return s
    end
    -- An animation: which entry animates each drawn model, and its material.
    local function compiledFor(name)
        local c=out.compiled[name]
        if c then return c end
        local animation=assert(package.animations[name],'Animation not in the package')
        c={compiled=modules.animation.compile(animation,modules,options),scales={},materials={},draws={}}
        for key,entry in ipairs(animation.entries) do
            if entry.type==1 then c.scales[key]={1,1,1}
            elseif entry.type==4 then
                local instance={[0x80]=0,[0x84]=0}
                local material=materials[entry.chunk or entry.target]
                if material then for offset,value in pairs(material.instance) do instance[offset]=f(value) end end
                c.materials[key]=instance
            end
        end
        -- An entry names its target: a coordinate (type 1) or a material (type 4)
        -- of its clump. A model hangs on the clump coordinate its header indexes.
        -- entry.target is the animation's instance name, entry.chunk the chunk it
        -- instances (they differ when a clump is instanced more than once).
        -- draw.materials: index in the model's material list -> entry animating it.
        for clumpIndex,clump in ipairs(animation.clumps) do
            for _,modelName in ipairs(clump.drawn or {}) do
                local model=assert(package.models[modelName])
                -- billboard: the nuccChunkBillboard keys of a billboard member, or nil.
                local draw={model=modelName,materials={},billboard=clump.billboards and clump.billboards[modelName]}
                local bone=clump.coords and clump.coords[model.header.bone+1]
                -- A skinned model: the entry animating each coordinate of its skeleton.
                local skeleton=skeletonOf(model)
                local coordinate,own={},{}
                if skeleton then
                    draw.skin={}
                    for i,name in ipairs(skeleton.coords) do coordinate[name]=i end
                    for _,chunk in ipairs(clump.boneChunks or {}) do own[chunk[2]]=true end
                end
                for key,entry in ipairs(animation.entries) do
                    if entry.clump_index==clumpIndex-1 then
                        local chunk=entry.chunk or entry.target
                        if entry.type==1 and chunk==bone then draw.coord=key end
                        if entry.type==1 and coordinate[chunk] then draw.skin[coordinate[chunk]]=key end
                        if entry.type==4 then
                            for index,material in ipairs(model.materials) do
                                if material.name==chunk then draw.materials[index]=key end
                            end
                        end
                    elseif skeleton and entry.type==1 and entry.clump_index>=0 then
                        -- An animation can list one clump chunk as several clumps, each
                        -- with a part of its coordinates (the four tails of 4mnreff1_tail00):
                        -- a bone this clump does not list is then animated in another. A
                        -- coordinate this clump lists itself is never taken from another
                        -- clump: that one is another copy of the chunk.
                        local other=animation.clumps[entry.clump_index+1]
                        local chunk=entry.chunk or entry.target
                        if other and other.chunk==clump.chunk and coordinate[chunk] and not own[chunk]
                            and not draw.skin[coordinate[chunk]] then
                            draw.skin[coordinate[chunk]]=key
                        end
                    end
                end
                c.draws[#c.draws+1]=draw
            end
        end
        out.compiled[name]=c
        return c
    end
    out.compiledFor=compiledFor
    -- Fresh material instances for one playing copy of an animation.
    function out.instances(c)
        local instances={}
        for key,fields in pairs(c.materials) do
            local copy={}
            for offset,value in pairs(fields) do copy[offset]=value end
            instances[key]=copy
        end
        return instances
    end
    -- Frame of a billboard member at `ticks` of its own clock. The clump advances
    -- the clock by the animation's delta (0x1412c7f90): past the total it wraps when
    -- the chunk loops, else it stops on the total; then the keys of frame
    -- floor(ticks / step) are copied (0x1412c7b00), none once the clock is past
    -- the last frame, which therefore stays (held here as the last frame).
    local function billboardFrame(board,ticks)
        local total=board.count*board.stepTicks
        if ticks>=total then ticks=board.loop and ticks%total or total end
        return math.min(math.floor(ticks/board.stepTicks),board.count-1)
    end
    out.billboardFrame=billboardFrame
    -- Material instance field each billboard channel replaces when the chunk has it
    -- (draw 0x1412c7dd0): UV sets 0 / 1 offset and scale, blend rate x / y, the
    -- header float, the outline id; channel 12 is the alpha threshold * 255.
    local BOARD_FIELDS={[5]={0x30,0x34},[6]={0x50,0x54},[10]={0x38,0x3c},[11]={0x58,0x5c},
        [7]={0x70},[8]={0x74},[9]={0x7c},[13]={0x84}}
    -- One drawn model of an evaluated animation: its matrix, the animated
    -- instance of each of its materials, and its opacity. The coordinate
    -- controller 0x1413679d0 writes the node opacity (nuccCoord +38) on every
    -- update: curve 3 of the coordinate, or 1 when the animation has none.
    -- ticks: the clock of the animation's billboard members (the sum of its deltas).
    function out.resolve(draw,result,fallbackMatrix,ticks)
        local coord=draw.coord and result[draw.coord]
        local instances={}
        for index,key in pairs(draw.materials) do instances[index]=result[key].instance end
        local resolved={model=draw.model,matrix=coord and coord.worldMatrix or fallbackMatrix,instances=instances,
            opacity=coord and (coord.channels[3] and coord.channels[3][1] or 1) or nil}
        if draw.billboard then
            -- A billboard member: its keys go into the material instances, its
            -- opacity channel (4) replaces the model opacity (+A0), and the facing
            -- hook takes its position offset (1), roll (2) and size (3); absent
            -- channels keep the defaults (offset 0, roll 0, size 1, 1).
            local board=draw.billboard
            local frame=billboardFrame(board,ticks or 0)
            local function key(n) local keys=board.channels[n] return keys and keys[math.min(frame+1,#keys)] end
            resolved.billboard={offset=key(1) or {0,0,0},size=key(3) or {1,1},
                roll=board.rolls and board.rolls[math.min(frame+1,#board.rolls)] or 0,frame=frame}
            resolved.alphaScale=key(4) and key(4)[1] or 1
            for index,material in ipairs(package.models[draw.model].materials) do
                local copy={}
                for offset,value in pairs(instances[index] or material.instance) do copy[offset]=value end
                for n,fields in pairs(BOARD_FIELDS) do
                    local value=key(n)
                    if value then for i,offset in ipairs(fields) do copy[offset]=f(value[i]) end end
                end
                if key(12) then copy[0x80]=f(key(12)[1]/255) end
                instances[index]=copy
            end
        end
        if draw.skin then
            -- Skinned model: every coordinate of its clump has a pose (its animated
            -- matrix, or its rest transform under its parent's pose). The model is
            -- drawn with the matrix that makes the palette entry of the root
            -- coordinate the identity, as in the captured palettes; the vertices
            -- are skinned in that matrix's space (skinning_core.lua).
            local s=skeletonOf(package.models[draw.model])
            local pose={}
            for i=1,#s.rest do
                local key=draw.skin[i]
                if key then pose[i]=result[key].worldMatrix
                else
                    local parent=s.parents[i]
                    pose[i]=modules.matrix.world(parent<0 and fallbackMatrix or pose[parent+1],s.restLocal[i],f)
                end
            end
            resolved.matrix=modules.matrix.world(pose[1],s.restInverse[1],f)
            local inverse=modules.skinning.inverse(resolved.matrix)
            -- A root coordinate scaled to zero flattens the whole model: nothing to draw.
            if inverse then resolved.palette=modules.skinning.palette(pose,s.restInverse,inverse,modules.matrix.multiply,f)
            else resolved.hidden=true end
        end
        return resolved
    end
    -- nuccChunkCoord local transform of a clump model (nuccCoord constructor
    -- 0x1412892a0): translation, Euler rotation, scale.
    local function nodeMatrix(base,node)
        if not node then return base end
        local localMatrix=modules.matrix.node(node.position,node.rotation,node.scale,f,options.sinf,options.cosf)
        return modules.matrix.world(base,localMatrix,f)
    end
    function out:update(p,rate)
        local resource=assert(package.resources[p.resource])
        if not p.modelDirection then p.modelDirection={0,0,0} end
        p.modelDirection=modules.particle.advanceDirection(p.previousPosition,p.position,p.modelDirection,f)
        local fields={position=p.position,direction=p.modelDirection,travelAligned=p.alignTravel,
            directionTolerance=.0010000000474974513,angles={p.rotation[1],p.rotation[2],p.rotation[3]},
            rotationDirty=true,parentScale={1,1,1},baseScale=p.scale,uniformScale=p.attachmentScale}
        local parent,enabled=modules.particle.parent(fields,modules.matrix,f,options.sinf,options.cosf)
        p.modelEnabled=enabled
        -- 0x14130b200 writes the size-curve output (+88) and hands the model the
        -- matrix +A0 that the particle mover built before that write, so a model
        -- shows the size of the previous update while its alpha is current.
        -- Capture 22127: shock09 has size at life fraction 4/8 with alpha at 4.5/8,
        -- nor_dst03 size at 4/6 with alpha at 4.5/6. Billboards read +88 directly.
        local size=p.modelSize or options.initialSize(p)
        p.modelSize={p.lifecycleSize[1],p.lifecycleSize[2],p.lifecycleSize[3]}
        p.modelUpdates=(p.modelUpdates or 0)+1
        local draws={}
        if resource.kind=='anm' then
            local c=compiledFor(resource.animation)
            if not p.modelInstance then
                p.modelInstance=modules.bridge.new(c.compiled,modules,{coordinateTranslationScales=c.scales,
                    materialInstances=out.instances(c)})
            end
            local result,_,_,scaled=p.modelInstance:update(parent,size,p.sampleConfig.simulationHz,rate,1)
            for i,draw in ipairs(c.draws) do draws[i]=out.resolve(draw,result,scaled,p.modelInstance.ticks) end
            -- The evaluated entries, for the trails of the animation (their edge coordinates).
            p.modelResult=result
        else
            -- Render 0x14130b64f: particle matrix +A0, columns scaled by +1B0.
            local base=modules.matrix.scaleColumns(parent,size,f)
            for i,name in ipairs(resource.models) do
                -- A skinned model of a clump nothing animates stays in its rest pose:
                -- its vertices are already in the clump's space.
                local model=package.models[name]
                local matrix=model.skeleton and base or nodeMatrix(base,model.node)
                local board=resource.billboards and resource.billboards[name]
                -- A billboard member keeps the keys of its frame 0: nothing advances the
                -- clock of an emitter clump's members (journal R102).
                draws[i]=board and out.resolve({model=name,materials={},billboard=board},{},matrix,0)
                    or {model=name,matrix=matrix}
            end
        end
        p.modelDraws=draws
        self.updates=self.updates+1
    end
    -- A model particle is not drawn on the frame it is born: the game's captures
    -- never show light00 at age 0.5 (three discs per frame, ages 1-3 or 1.5-3.5),
    -- consistent with the mover not having built its matrix yet.
    function out:draws(p)
        if not p.modelDraws or not p.modelEnabled or p.modelUpdates<2 then return nil end
        return p.modelDraws
    end
    function out:world(matrix,outerMatrix) return modules.matrix.world(outerMatrix,matrix,f) end
    return out
end
return P
