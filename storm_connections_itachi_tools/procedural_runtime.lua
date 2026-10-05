-- File-derived particle stepping. No snapshot interpolation is used.
-- Resolved spawn transforms, field order and parent displacement are required
-- inputs until the original scene graph/control paths are fully reconstructed.
local P={}
function P.new(motion,spawn,curves)
    local runtime={}
    function runtime.create(e,rng,resolveSpawn,resourceAvailable)
        local resource=spawn.resource(e.resources,rng)
        local life=spawn.lifetime(e.life,e.lifeRandom,rng)
        if life==0 then return nil,'original zero lifetime' end
        local scalar=spawn.scalar(e.scalarBase,e.scalarRandom,rng)
        -- The resolver must consume the original attachment and shape RNG,
        -- not substitute recorded centers or visual estimates.
        local spatial,why=resolveSpawn(e,rng)
        if not spatial then return nil,why end
        local velocity
        velocity,why=spawn.velocity(e,spatial.position,spatial.center,spatial.direction,
            spatial.scale,rng,spatial.coneTransform)
        if not velocity then return nil,why end
        local rotation={0,0,0}
        local function angle()
            local a=rng:range(2*math.pi)
            if a>math.pi then a=a-2*math.pi end
            return a
        end
        if e.rotation==1 then for i=1,3 do rotation[i]=angle() end
        elseif e.rotation==3 then rotation[2]=angle() end
        local sizes=spawn.sizeCurves(e,rng)
        local sampleConfig={}
        for k,v in pairs(e) do sampleConfig[k]=v end
        for k,v in pairs(sizes) do sampleConfig[k]=v end
        sampleConfig.sizeRandom={0,0,0} -- RNG applied once at birth above.
        -- Unsupported rendering must not change the global RNG stream.
        if resourceAvailable and not resourceAvailable(resource) then
            return nil,'resource player not implemented: '..resource
        end
        return {resource=resource,life=life,ageTicks=0,position=spatial.position,
            fade=curves.fadeInit(life,e.fadeIn,e.fadeOut),
            attachmentScale=spatial.scale,previousPosition={spatial.position[1],spatial.position[2],spatial.position[3]},
            velocity=velocity,secondaryVelocity={0,0,0},displacement={0,0,0},
            rotation=rotation,scale={1,1,1},speed=1,scalar=scalar,
            sampleConfig=sampleConfig,alive=true,alignTravel=e.rotation==2 or e.rotation==3}
    end
    function runtime.step(p,seconds,fields,parentDisplacement)
        if not p.alive then return false end
        p.previousPosition={p.position[1],p.position[2],p.position[3]}
        local step=seconds*p.sampleConfig.simulationHz
        for _,field in ipairs(fields) do
            local ok,why=motion.force(p,field,step)
            if not ok then return nil,why end
        end
        motion.integrate(p,step,parentDisplacement)
        p.ageTicks=p.ageTicks+step
        p.alive=p.ageTicks<p.life
        local age=p.ageTicks/p.sampleConfig.simulationHz
        p.size,p.color=curves.sample(p.sampleConfig,p.life,age,{0,0,0})
        -- 0x14130b436: alpha is the colour curve's alpha times the fade state.
        p.alpha=p.color[4]*curves.fadeStep(p.fade,p.ageTicks,step)
        p.lifecycleSize={p.size[1],p.size[2],p.size[3]}
        for i=1,3 do p.size[i]=p.size[i]*p.scale[i] end
        return p.alive
    end
    return runtime
end
return P
