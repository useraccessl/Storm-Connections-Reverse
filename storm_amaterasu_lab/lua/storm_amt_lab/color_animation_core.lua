-- Original nuccAnmKey_ColorRgbTbl, 0x141395000. Always linear between keys.
local C={}
function C.sample(curve,ticks,step,f)
    assert(curve.format==20 and step>0 and ticks>=0 and ticks==math.floor(ticks))
    local index=math.floor(ticks/step)+1
    local a=assert(curve.values[index],'RGB clock outside domain')
    local out={} local remainder=ticks%step
    if remainder==0 then
        for i=1,3 do out[i]=f(f(a[i])/255) end
    else
        local b=assert(curve.values[index+1],'RGB reader requires next key')
        local t=f(f(remainder)/f(step)) local inverse=f(1-t)
        for i=1,3 do out[i]=f(f(f(f(b[i])*t)+f(f(a[i])*inverse))/255) end
    end
    return out
end
return C
