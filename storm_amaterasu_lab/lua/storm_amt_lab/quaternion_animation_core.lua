-- Original quaternion interpolation 0x1411f4e90.
-- Inputs must already have the native quaternion conversion applied.
-- Caller provides float32, acosf and sinf; GMod trig parity is unverified.
local Q={}
function Q.interpolate(a,b,t,f,acosf,sinf)
    local p={} for i=1,4 do p[i]=f(a[i]*b[i]) end
    local dot=f(f(p[1]+p[3])+f(p[2]+p[4]))
    local sign=1
    if dot<0 then dot=-dot sign=-1 end
    local wa=f(1-t) local wb=t
    if dot<=0.9700000286102295 then
        local angle=acosf(dot)
        local inverse=f(1/sinf(angle))
        wa=f(sinf(f(wa*angle))*inverse)
        wb=f(sinf(f(angle*t))*inverse)
    end
    wa=f(wa*sign)
    local out={}
    for i=1,4 do out[i]=f(f(wa*a[i])+f(wb*b[i])) end
    local sq={} for i=1,4 do sq[i]=f(out[i]*out[i]) end
    local length=f(math.sqrt(f(f(sq[1]+sq[3])+f(sq[2]+sq[4]))))
    if length>=9.999999747378752e-05 then
        local inverse=f(1/length)
        for i=1,4 do out[i]=f(inverse*out[i]) end
    end
    return out
end
function Q.normalize(a,f)
    local sq={} for i=1,4 do sq[i]=f(a[i]*a[i]) end
    local length=f(math.sqrt(f(f(sq[1]+sq[3])+f(sq[2]+sq[4]))))
    local out={a[1],a[2],a[3],a[4]}
    if length>=9.999999747378752e-05 then
        local inverse=f(1/length)
        for i=1,4 do out[i]=f(inverse*a[i]) end
    end
    return out
end
function Q.convert(a) return {-a[1],-a[2],-a[3],a[4]} end
function Q.prepareCompressed(curve,f)
    assert(curve.format==17 or curve.format==27,'unsupported compressed quaternion format')
    local out={format=curve.format,values={}}
    for index,raw in ipairs(curve.values) do
        local decoded={} for i=1,4 do decoded[i]=f(raw[i]*6.103515625e-05) end
        local normalized=Q.normalize(decoded,f)
        local compressed={}
        for i=1,4 do
            local value=f(normalized[i]*16384)
            compressed[i]=value<0 and math.ceil(value) or math.floor(value)
        end
        out.values[index]=compressed
    end
    return out
end
function Q.sampleCompressed(prepared,step,ticks,f,acosf,sinf)
    assert(step>0 and step==math.floor(step),'native step must be positive integer')
    assert(ticks>=0 and ticks==math.floor(ticks) and ticks<4294967296,'native clock must be uint32')
    local index=math.floor(ticks/step)+1
    local function decode(key)
        assert(key,'clock outside native quaternion domain')
        local out={} for i=1,4 do out[i]=f(key[i]*6.103515625e-05) end
        return Q.convert(out)
    end
    local a=decode(prepared.values[index])
    local remainder=ticks%step
    if prepared.format==27 or remainder==0 then return a end
    assert(prepared.format==17,'unsupported quaternion reader')
    return Q.interpolate(a,decode(prepared.values[index+1]),f(f(remainder)/f(step)),f,acosf,sinf)
end
-- Packed 3x3 basis written by 0x1411bb590, before matrix layout adaptation.
function Q.basis(a,f)
    local x,y,z,w=a[1],a[2],a[3],a[4]
    local xx,yy,zz=f(x*x),f(y*y),f(z*z)
    local xy,xz,yz=f(y*x),f(z*x),f(z*y)
    local wy,wz,wx=f(w*y),f(w*z),f(w*x)
    local function twice(v) return f(v+v) end
    return {f(1-twice(f(yy+zz))),twice(f(xy-wz)),twice(f(xz+wy)),
        twice(f(wz+xy)),f(1-twice(f(xx+zz))),twice(f(yz-wx)),
        twice(f(xz-wy)),twice(f(wx+yz)),f(1-twice(f(xx+yy)))}
end
-- Timestamp reader 0x141391db0. -1 in exported files is UINT32_MAX sentinel.
function Q.prepareTimestamp(curve,f)
    assert(curve.format==10 and #curve.values>=2)
    local out={format=10,values={},cursor=1}
    for index,row in ipairs(curve.values) do
        local key={row[1]%4294967296}
        for i=2,5 do key[i]=f(row[i]) end
        if index>1 then assert(key[1]>out.values[index-1][1],'Timestamp keys must increase') end
        out.values[index]=key
    end
    return out
end
function Q.sampleTimestamp(prepared,ticks,f,acosf,sinf)
    assert(ticks>=0 and ticks==math.floor(ticks) and ticks<4294967296)
    local keys=prepared.values
    assert(ticks>=keys[1][1] and ticks<keys[#keys][1],'Timestamp reader requires next sentinel key')
    local index=prepared.cursor
    while keys[index+1][1]<=ticks do index=index+1 end
    while keys[index][1]>ticks do index=index-1 end
    prepared.cursor=index
    local a,b=keys[index],keys[index+1]
    local ratio=f(f(ticks-a[1])/f(b[1]-a[1]))
    local left=Q.convert({a[2],a[3],a[4],a[5]})
    local right=Q.convert({b[2],b[3],b[4],b[5]})
    return Q.interpolate(left,right,ratio,f,acosf,sinf)
end
return Q
