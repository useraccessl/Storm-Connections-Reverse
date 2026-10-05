-- Colour curves of the game's animations (nuccAnmKey_ColorRgbTbl, game: 0x141395000): one
-- key every iStep ticks, linear between two keys, from 0..255 to 0..1.

StormFX.Core.ColorAnimation = StormFX.Core.ColorAnimation or {}

local COLOR_ANIMATION = StormFX.Core.ColorAnimation

-- The colour {r, g, b} of a curve at iTicks
function COLOR_ANIMATION.Sample(tCurve, iTicks, iStep, fnFloat32)

    assert(tCurve.format == 20 and iStep > 0 and iTicks >= 0 and iTicks == math.floor(iTicks))

    local iIndex = math.floor(iTicks / iStep) + 1
    local tKey = assert(tCurve.values[iIndex], "Colour curve: the clock is past its keys")
    local iRemainder = iTicks % iStep
    local tColor = {}

    if iRemainder == 0 then

        for i = 1, 3 do
            tColor[i] = fnFloat32(fnFloat32(tKey[i]) / 255)
        end

    else

        local tNextKey = assert(tCurve.values[iIndex + 1], "Colour curve: no key after the last one")
        local flT = fnFloat32(fnFloat32(iRemainder) / fnFloat32(iStep))
        local flInverse = fnFloat32(1 - flT)

        for i = 1, 3 do
            tColor[i] = fnFloat32(fnFloat32(fnFloat32(fnFloat32(tNextKey[i]) * flT) + fnFloat32(fnFloat32(tKey[i]) * flInverse)) / 255)
        end

    end

    return tColor

end

return COLOR_ANIMATION
