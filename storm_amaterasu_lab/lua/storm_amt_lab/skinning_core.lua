-- NUD skinning as the game does it: a compute shader run once per skinned mesh
-- (captured in RenderDoc, gpu_captures/compute/shader_*.dxbc; it is in no file
-- of the game). Per vertex it blends the three first columns of the palette
-- matrices of the four influences by their weights, then
--   position.xyz = (dot(R1, p), dot(R2, p), dot(R3, p)), position.w kept
--   normal       = (dot(R1.xyz, n), dot(R2.xyz, n), dot(R3.xyz, n))   -- not renormalised
-- A palette matrix is sixteen floats as the shader reads them (row vectors:
-- translation in elements 13..15), so column k is elements k, k+4, k+8, k+12.
-- The palette has one matrix per coordinate of the model's clump:
--   transpose(pose * inverse(rest)), pose and rest in the model's own space.
-- f rounds to float32 (the engine passes the identity: doubles).
-- verify_skinning_capture.py compares S.vertex with the output buffer of the
-- captured dispatches, verify_skin_palette_capture.py checks the palette rule.
local S={}
-- weights {w1..w4}, indices {i1..i4} (1-based into palette), position {x,y,z,w},
-- normal {x,y,z}. The accumulation order is the shader's: influence 2 first.
function S.vertex(position,normal,weights,indices,palette,f)
    local a,b,c,d=palette[indices[1]],palette[indices[2]],palette[indices[3]],palette[indices[4]]
    local w1,w2,w3,w4=weights[1],weights[2],weights[3],weights[4]
    local p,n={},{}
    for k=1,3 do
        local r1=f(f(f(f(w2*b[k])+f(a[k]*w1))+f(c[k]*w3))+f(d[k]*w4))
        local r2=f(f(f(f(w2*b[k+4])+f(a[k+4]*w1))+f(c[k+4]*w3))+f(d[k+4]*w4))
        local r3=f(f(f(f(w2*b[k+8])+f(a[k+8]*w1))+f(c[k+8]*w3))+f(d[k+8]*w4))
        local r4=f(f(f(f(w2*b[k+12])+f(a[k+12]*w1))+f(c[k+12]*w3))+f(d[k+12]*w4))
        p[k]=f(f(f(f(r1*position[1])+f(r2*position[2]))+f(r3*position[3]))+f(r4*position[4]))
        n[k]=f(f(f(r1*normal[1])+f(r2*normal[2]))+f(r3*normal[3]))
    end
    p[4]=position[4]
    return p,n
end
-- Inverse of an affine matrix in the engine's layout (rows of a 3x4 transform:
-- translation in elements 4, 8, 12); nil for a matrix that flattens space (an
-- animation scales a coordinate to zero to hide what hangs from it).
function S.inverse(m)
    local a,b,c,d,e,g,h,i,j=m[1],m[2],m[3],m[5],m[6],m[7],m[9],m[10],m[11]
    local A,B,C=e*j-g*i,g*h-d*j,d*i-e*h
    local det=a*A+b*B+c*C
    if det==0 or det~=det then return nil end
    local r={A/det,(c*i-b*j)/det,(b*g-c*e)/det,0,B/det,(a*j-c*h)/det,(c*d-a*g)/det,0,C/det,(b*h-a*i)/det,(a*e-b*d)/det,0,0,0,0,1}
    local x,y,z=m[4],m[8],m[12]
    r[4]=-(r[1]*x+r[2]*y+r[3]*z)
    r[8]=-(r[5]*x+r[6]*y+r[7]*z)
    r[12]=-(r[9]*x+r[10]*y+r[11]*z)
    return r
end
local function transposed(m)
    return {m[1],m[5],m[9],m[13],m[2],m[6],m[10],m[14],m[3],m[7],m[11],m[15],m[4],m[8],m[12],m[16]}
end
-- The palette of a skinned model, as the shader reads it. pose[i]: matrix of
-- clump coordinate i in the space the effect is evaluated in; restInverse[i]:
-- inverse of its rest matrix in the clump's space; drawInverse: inverse of the
-- matrix the model is drawn with (the one that makes entry 1 the identity).
function S.palette(pose,restInverse,drawInverse,multiply,f)
    local out={}
    for i=1,#pose do out[i]=transposed(multiply(drawInverse,multiply(pose[i],restInverse[i],f),f)) end
    return out
end
-- A whole mesh: definition.vertices {{x,y,z,...}}, definition.skin {normals,
-- indices (0-based, as in the NUD), weights, positionW or nil}. Returns
-- positions {{x,y,z}} and normals {{x,y,z}}.
function S.mesh(definition,palette,f)
    local skin=definition.skin
    local positions,normals={},{}
    local index={0,0,0,0}
    for v,vertex in ipairs(definition.vertices) do
        local bones=skin.indices[v]
        index[1],index[2],index[3],index[4]=bones[1]+1,bones[2]+1,bones[3]+1,bones[4]+1
        positions[v],normals[v]=S.vertex({vertex[1],vertex[2],vertex[3],skin.positionW and skin.positionW[v] or 1},
            skin.normals[v],skin.weights[v],index,palette,f)
    end
    return positions,normals
end
return S
