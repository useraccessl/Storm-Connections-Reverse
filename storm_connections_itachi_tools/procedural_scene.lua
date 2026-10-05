-- Reusable scene runner. All birth/position inputs come from effect files.
-- The host must provide animation coordinates, force routing and activation.
-- Fixed updates make diagnostics deterministic; they do not claim to match
-- the original host's scheduler, global seed or skill projectile trajectory.
local S={}
function S.new(data,name,modules,options)
    options=options or {}
    local scene={name=name,frame=0,particles={},births={},errors={},stopNotifications={},
        fps=options.fps or 60,rng=modules.spawn.random(options.seed or 1),emitters={}}
    local runtime=modules.runtime.new(modules.motion,modules.spawn,modules.curves)
    local records=assert(data.spatialRecords[name],'missing spatial records')
    local coords,why
    if options.coordinates then coords=options.coordinates
    else coords,why=modules.spatial.coordinates(data.animations[name],options.sampleAnimated) end
    if not coords then return nil,why end
    -- options.externalCoordinate(name): host value for a coordinate outside the effect.
    local external=options.externalCoordinate
    for _,e in ipairs(assert(data.effects[name],'missing effect')) do
        local attachments=assert(modules.spatial.attachments(records.attachments,coords,e.id,external))
        local fields=assert(modules.spatial.fields(records.forces,coords,e.id,external))
        scene.emitters[#scene.emitters+1]={config=e,state=modules.emission.new(false),particles={},
            attachments=attachments,segments=modules.spatial.segments(attachments),fields=fields,
            routedFields=modules.motion.routeFields(assert(e.forceMask,'missing original force mask'),
                {fields,options.context88Fields or {},options.context80Fields or {}})}
    end
    function scene:stopEmission()
        if self.emissionStopped then return end
        self.emissionStopped=true
        for _,g in ipairs(self.emitters) do modules.emission.stop(g.state) end
    end
    function scene:isDrained() return #self.particles==0 end
    function scene:update()
        local clock=self.frame*1000/self.fps
        if options.updateCoordinates then
            local current=assert(options.updateCoordinates(self.frame),'Missing ANM coordinates')
            for _,g in ipairs(self.emitters) do
                g.attachments=assert(modules.spatial.attachments(records.attachments,current,g.config.id,external))
                g.segments=modules.spatial.segments(g.attachments)
                g.fields=assert(modules.spatial.fields(records.forces,current,g.config.id,external))
                g.routedFields=modules.motion.routeFields(g.config.forceMask,
                    {g.fields,options.context88Fields or {},options.context80Fields or {}})
            end
        end
        if options.stopEmission and options.stopEmission(self.frame) then
            self:stopEmission()
        end
        for _,g in ipairs(self.emitters) do
            local e=g.config
            if options.resolveFrame then
                options.resolveFrame(g,clock)
                g.routedFields=modules.motion.routeFields(e.forceMask,
                    {g.fields,options.context88Fields or {},options.context80Fields or {}})
            end
            local count,_,notify=modules.emission.update(g.state,e,clock,self.fps,1,#g.attachments)
            if notify then self.stopNotifications[#self.stopNotifications+1]={emitter=e.id,clock=clock} end
            for _=1,math.max(0,count) do
                local p,reason=runtime.create(e,self.rng,function(config,rng)
                    if config.shape>=3 and #g.attachments>1 then
                        return modules.birthSpatial.segment(config,rng,g.segments)
                    end
                    return modules.birthSpatial.single(config,rng,g.attachments)
                end)
                if p then
                    p.emitter=e.id p.generator=g
                    g.particles[#g.particles+1]=p
                    self.particles[#self.particles+1]=p
                    -- An emitter without a resource still makes particles (particle_spawn_core).
                    local key=p.resource or '(no resource)'
                    self.births[key]=(self.births[key] or 0)+1
                else self.errors[#self.errors+1]={emitter=e.id,clock=clock,reason=reason} end
            end
            -- Original generator emits before updating its particle list.
            local alive={}
            for _,p in ipairs(g.particles) do if p.alive then
                -- 0x1412765c0 attaches generator-local fields to +90.
                -- Host +88/+80 lists must be supplied by the skill scene.
                local fields=options.routeFields and options.routeFields(g,p) or g.routedFields
                local ok,reason=runtime.step(p,1/self.fps,fields,{0,0,0})
                if ok==nil then error(reason) end
                if options.afterParticleStep then options.afterParticleStep(p,self.fps) end
                if p.alive then alive[#alive+1]=p end
            end end
            g.particles=alive
        end
        local alive={}
        for _,p in ipairs(self.particles) do if p.alive then alive[#alive+1]=p end end
        self.particles=alive self.frame=self.frame+1
    end
    return scene
end
return S
