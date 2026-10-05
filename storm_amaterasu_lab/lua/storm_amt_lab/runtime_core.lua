-- Pure Lua evaluator of decoded fields. Source rendering is in decoded_client.lua.
local R = {}
local function lerp(a,b,t)
    local out={} for i=1,#a do out[i]=a[i]+(b[i]-a[i])*t end return out
end
function R.curve(a,b,c,split,t,size)
    t=math.max(0,math.min(1,t))
    if size and split==0 then return a end
    if split>0 and t<split then return lerp(a,b,t/split) end
    if split==1 then return b end
    return lerp(b,c,(t-split)/(1-split))
end
function R.sample(e,life,age,random)
    local t=math.min(1,age*e.simulationHz/life)
    local size=R.curve(e.sizeStart,e.sizeMiddle,e.sizeEnd,e.sizeSplit,t,true)
    local scaled={} for i=1,3 do scaled[i]=size[i]*(1+(random[i] or 0)*e.sizeRandom[i]) end
    local color=R.curve(e.colorStart,e.colorMiddle,e.colorEnd,e.colorSplit,t,false)
    local fade=1
    if e.fadeIn>0 then fade=math.min(fade,t/e.fadeIn) end
    local fadeStart=(life-math.floor(life*e.fadeOut))/life
    if e.fadeOut>0 and t>fadeStart then
        fade=math.min(fade,1-(t-fadeStart)/e.fadeOut)
    end
    return scaled,color,math.max(0,fade)*color[4]
end
-- Particle fade as the game runs it: initializer 0x14130c350, per-update state
-- machine 0x14130b3a3..0x14130b436 (state at particle+184, value at +68).
-- It differs from the closed form in R.sample by one update at each end: the
-- update that detects `age > start` only switches to fading out, and the value
-- starts to fall on the next one. Capture check: light00 keeps 0.0884 (colour
-- alpha 0.0983 * node opacity 0.9, fade still 1) at age 3.5 of 4.
function R.fadeInit(life,fadeIn,fadeOut)
    local state={rateIn=0,rateOut=0,value=0,mode=0}
    if life*fadeIn~=0 then state.rateIn=1/(life*fadeIn) end
    local span=life*fadeOut
    if span~=0 then state.rateOut=1/span end
    state.start=life-(span>=0 and math.floor(span) or math.ceil(span))
    -- With no fade-in the particle starts opaque, unless it would fade out at once.
    if fadeIn==0 and state.start~=0 then state.value=1 state.mode=1 end
    return state
end
-- age is the particle age after this update's increment; step is that increment.
function R.fadeStep(state,age,step)
    if state.mode==0 then
        state.value=state.value+step*state.rateIn
        if state.value>=1 then state.value=1 state.mode=1 end
    elseif state.mode==1 then
        if age>state.start then state.mode=2 end
    elseif state.mode==2 then
        state.value=state.value-step*state.rateOut
        if state.value<=0 then state.value=0 state.mode=3 end
    end
    return state.value
end
function R.billboard(b,age)
    local tick=math.floor(age*3000)
    local duration=b.count*b.stepTicks
    if b.loop then tick=tick%duration end
    local index=math.min(b.count,math.floor(tick/b.stepTicks)+1)
    local out={}
    for channel,keys in pairs(b.channels) do out[channel]=keys[math.min(index,#keys)] end
    return out,index
end
-- Particle renderer 0x14130b4a0 advances the billboard once for every whole
-- simulation counter step. 0x1412c7d48 adds floor(3000/60)=50 clock ticks
-- per advance. Wall-clock seconds alone therefore give the wrong rate when
-- an emitter overrides its simulation Hz (the Amaterasu emitters use 30).
function R.billboardFromParticle(b,ageTicks)
    -- 0x1412c7b00 copies channels at the OLD clock, then advances it.
    -- The last whole update therefore exposes (whole-1)*50, not whole*50.
    -- Joint UV/color/opacity audit: 130/147 secondary draws compatible,
    -- versus 84/147 for sampling after increment. Remaining draws differ.
    local ticks=math.max(0,math.floor(ageTicks)-1)*50
    local duration=b.count*b.stepTicks
    if b.loop then ticks=ticks%duration end
    local index=math.min(b.count,math.floor(ticks/b.stepTicks)+1)
    local out={}
    for channel,keys in pairs(b.channels) do out[channel]=keys[math.min(index,#keys)] end
    return out,index,ticks
end
function R.births(e,seconds,fps)
    local active=false local accumulator=0 local out={} local eventIndex=1
    for frame=0,math.floor(seconds*fps) do
        local time=frame/fps
        while e.events[eventIndex] and e.events[eventIndex].clock_threshold_ms<=math.floor(time*1000) do
            active=e.events[eventIndex].action=='start_emission'
            eventIndex=eventIndex+1
        end
        if active then
            local count
            if e.direct then count=math.floor(e.quantity) active=false
            else accumulator=accumulator+e.quantity/fps count=math.floor(accumulator+1e-12) accumulator=accumulator-count end
            for _=1,count do out[#out+1]=time end
        end
    end
    return out
end
function R.animation(curve,step,ticks)
    local values=curve.values
    if #values==1 then return values[1] end
    local timestamped=curve.format==6 or curve.format==10 or curve.format==12
    local index=1
    if timestamped then
        while index<#values and values[index+1][1]<=ticks do index=index+1 end
    else index=math.min(#values,math.floor(ticks/step)+1) end
    local a,b=values[index],values[math.min(index+1,#values)]
    local ta=timestamped and a[1] or (index-1)*step
    local tb=timestamped and b[1] or index*step
    local t=tb>ta and math.max(0,math.min(1,(ticks-ta)/(tb-ta))) or 0
    if curve.format==26 or curve.format==27 then t=0 end
    local start=timestamped and 2 or 1
    local out={} for i=start,#a do out[#out+1]=a[i]+(b[i]-a[i])*t end
    if curve.format==17 or curve.format==27 then
        local len=0 for i=1,4 do len=len+out[i]^2 end len=math.sqrt(len)
        for i=1,4 do out[i]=out[i]/len end
    end
    return out
end
return R
