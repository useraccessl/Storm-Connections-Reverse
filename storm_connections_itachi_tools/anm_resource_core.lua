-- File-driven ANM resource evaluator. Caller must supply the native local clock
-- and the material factory's hold mode. No world-placement or host guesses.
local A={}
-- 0x1413904d0, conditional channels; fixed channels ignore this flag.
function A.materialHoldFromContext(updateRate, forceLinearFlag)
    assert(type(updateRate)=='number' and type(forceLinearFlag)=='number')
    return updateRate==60 and forceLinearFlag==0
end
function A.compile(animation,modules,options)
    local compiled={step=animation.frame_step_ticks,duration=animation.duration_ticks,
        loop=animation.loop,parents=animation.parents or {},entries={},modules=modules,options=options,rest={}}
    local Q=assert(modules.quaternion) local f=assert(options.float32)
    -- Rest local matrix of every coordinate the animation lists (nuccCoord
    -- constructor 0x1412892a0), by 'clump:bone': what a coordinate keeps when no
    -- entry animates it.
    for clumpIndex,clump in ipairs(animation.clumps or {}) do
        for boneIndex,v in ipairs(clump.rest or {}) do
            if v then
                compiled.rest[(clumpIndex-1)..':'..(boneIndex-1)]=modules.matrix.node({v[1],v[2],v[3]},{v[4],v[5],v[6]},
                    {v[7],v[8],v[9]},f,options.sinf,options.cosf)
            end
        end
    end
    assert(type(options.materialHold)=='boolean','Explicit material factory mode required')
    -- Key classes with a recovered reader (factory 0x141367040), per entry type
    -- and, for coordinates, per channel: 0 position, 1 rotation, 2 scale, 3 opacity.
    local COORDINATE={[0]={[5]=true,[6]=true,[21]=true,[26]=true},{[8]=true,[10]=true,[17]=true,[27]=true},
        {[5]=true,[6]=true,[16]=true,[21]=true,[26]=true},{[11]=true,[12]=true,[15]=true,[22]=true,[24]=true,[29]=true}}
    local MATERIAL={[11]=true,[12]=true,[22]=true,[24]=true}
    local LIGHT={[5]=true,[6]=true,[11]=true,[20]=true,[22]=true}
    compiled.ignored={}
    for _,entry in ipairs(animation.entries) do
        local out={type=entry.type,target=entry.target,clump=entry.clump_index,bone=entry.bone_index,curves={}}
        if entry.type~=1 and entry.type~=4 and entry.type~=6 then
            -- Camera (2), directional light (5) and the other entry types met in
            -- effect files do not move coordinates or materials: kept in place
            -- (entry indices are keys) and not evaluated.
            out.ignored=true
            compiled.ignored[entry.type]=(compiled.ignored[entry.type] or 0)+1
        else
            for _,curve in ipairs(entry.curves) do
                local format=curve.format
                if entry.type==1 then
                    assert(COORDINATE[curve.index] and COORDINATE[curve.index][format],
                        'coordinate curve '..curve.index..' reader not recovered: format '..format)
                elseif entry.type==4 then assert(MATERIAL[format],'material curve reader not recovered: '..format)
                else assert(LIGHT[format],'point-light curve reader not recovered: '..format) end
                if format==17 or format==27 then out.curves[curve.index]=Q.prepareCompressed(curve,f)
                elseif format==10 then out.curves[curve.index]=Q.prepareTimestamp(curve,f)
                elseif format==8 then
                    -- Fixed Euler rotation: degrees (x, y, z), built once into a matrix like a
                    -- node's rotation (key constructor case of 0x141367040, 0x14127fea0).
                    assert(#curve.values==1,'format 8 is a constant rotation reader')
                    local function radians(degrees) return f(f(degrees*f(3.1415927410125732))/180) end
                    local v=curve.values[1]
                    out.curves[curve.index]={format=8,matrix=modules.matrix.euler(radians(v[1]),radians(v[2]),radians(v[3]),
                        f,options.sinf,options.cosf)}
                else out.curves[curve.index]=curve end
            end
        end
        compiled.entries[#compiled.entries+1]=out
    end
    return compiled
end
function A.evaluate(compiled,ticks,materialInstances)
    assert(ticks>=0 and ticks==math.floor(ticks),'caller must supply integer native ticks')
    -- Wrap/clamp belongs to the host; do not infer it from frame count alone.
    local modules,options=compiled.modules,compiled.options
    local f=options.float32 local out={}
    for key,entry in ipairs(compiled.entries) do
        local item={type=entry.type,target=entry.target,clump=entry.clump,bone=entry.bone}
        if entry.ignored then
            item.ignored=true
        elseif entry.type==1 then
            item.channels={}
            for index,curve in pairs(entry.curves) do
                if curve.format==10 then
                    item.channels[index]=modules.quaternion.sampleTimestamp(curve,ticks,f,options.acosf,options.sinf)
                elseif curve.format==17 or curve.format==27 then
                    item.channels[index]=modules.quaternion.sampleCompressed(curve,compiled.step,ticks,f,options.acosf,options.sinf)
                elseif curve.format==8 then item.channels[index]={matrix=curve.matrix}
                elseif index==3 then item.channels[index]={modules.scalar.sample(curve,ticks,compiled.step,false,f)}
                else item.channels[index]=modules.scalar.vector(curve,ticks,compiled.step,f) end
            end
            if item.channels[1] and not item.channels[1].matrix then item.rotationBasis=modules.quaternion.basis(item.channels[1],f) end
        elseif entry.type==6 then
            local channels={}
            for index,curve in pairs(entry.curves) do
                if curve.format==20 then
                    channels[index]=assert(modules.color).sample(curve,ticks,compiled.step,f)
                elseif curve.format==5 or curve.format==6 then channels[index]=modules.scalar.vector(curve,ticks,compiled.step,f)
                else channels[index]=modules.scalar.sample(curve,ticks,compiled.step,false,f) end
            end
            for index=0,4 do assert(channels[index],'Original point-light controller requires channel '..index) end
            item.channels=channels
            item.fields={ [0x50]=channels[0][1],[0x54]=channels[0][2],[0x58]=channels[0][3],[0x5c]=1,
                [0x60]=channels[1],[0x70]=channels[2][1],[0x74]=channels[2][2],[0x78]=channels[2][3],
                [0x88]=channels[3],[0x8c]=channels[4] }
        else
            local instance=assert(materialInstances[key],'original constructor fields required for material entry '..key)
            modules.material.evaluateDirect(instance,function(index)
                local curve=entry.curves[index]
                if not curve then return nil end
                -- Factory forces linear for channels 12..17 and 22.
                local hold=(index<12 or (index>=18 and index<=21)) and options.materialHold
                return modules.scalar.sample(curve,ticks,compiled.step,hold,f)
            end,f)
            item.instance=instance
        end
        out[key]=item
    end
    return out
end
-- Original effect controller owns the local clock; host delta remains external.
function A.newPlayer(compiled, ticks, speed)
    local clock=assert(compiled.modules.clock, 'ANM clock module required')
    return {compiled=compiled, clock=clock.new(compiled.duration,compiled.loop,ticks,speed)}
end
function A.advance(player, delta, materialInstances)
    local compiled=player.compiled
    local result,step=compiled.modules.clock.advance(player.clock,delta,compiled.options.float32)
    return A.evaluate(compiled,player.clock.ticks,materialInstances),result,step
end
-- Explicit caller context keeps particle/host placement out of the ANM parser.
-- rootMatrix: parent of the coordinates that have none; needed only when an
-- animated coordinate hangs from one the animation does not animate (that one
-- keeps its rest transform under its own parent).
function A.coordinateMatrices(compiled,evaluated,coordinateContexts,rootMatrix)
    local M=assert(compiled.modules.matrix,'Original matrix module required')
    local f=compiled.options.float32 local nodes={} local parentOf={}
    local function id(clump,bone) return clump..':'..bone end
    for _,link in ipairs(compiled.parents) do parentOf[id(link[3],link[4])]=id(link[1],link[2]) end
    for key,item in ipairs(evaluated) do if item.type==1 then
        local context=assert(coordinateContexts[key],'Missing original coordinate context')
        item.localMatrix=M.coordinate(item.channels,context.translationScale,compiled.modules.quaternion,f)
        nodes[id(item.clump,item.bone)]={item=item,context=context}
    end end
    local visiting={}
    local function resolve(name)
        local node=nodes[name]
        if not node then
            local rest=compiled.rest and compiled.rest[name]
            assert(rest and rootMatrix,'Missing animated parent coordinate '..name)
            node={item={localMatrix=rest},context={parentMatrix=rootMatrix}}
            nodes[name]=node
        end
        if node.item.worldMatrix then return node.item.worldMatrix end
        assert(not visiting[name],'Cyclic ANM parent hierarchy') visiting[name]=true
        local parent=parentOf[name] and resolve(parentOf[name]) or assert(node.context.parentMatrix,'Original root parent required')
        node.item.worldMatrix=M.world(parent,node.item.localMatrix,f)
        visiting[name]=nil
        return node.item.worldMatrix
    end
    -- Entry order, not pairs(nodes): resolve() adds rest parents to nodes, and a
    -- table that grows during pairs() can skip keys (journal R97).
    for _,item in ipairs(evaluated) do if item.type==1 then resolve(id(item.clump,item.bone)) end end
    return evaluated
end

return A
