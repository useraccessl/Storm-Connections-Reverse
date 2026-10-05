local assets = include("storm_amt_lab/generated.lua")
local billboardKeys = include("storm_amt_lab/billboard_keys.lua")
local labVersion = "2026-10-01-decoded-runtime-10"
local active
local sequence
local cache = {}
local flashMaterial = Material("storm_amt_lab/2efb_amt05")

local function get_mesh(name, frame, tint, noFilm, screenMix)
    local tintKey = tint and (tostring(tint[1]) .. ":" .. tostring(tint[2]) .. ":" .. tostring(tint[3])) or "source"
    local key = name .. ":" .. frame .. ":" .. tintKey .. (screenMix and ":screenmix" or noFilm and ":plain" or ":film")
    if cache[key] then return cache[key] end
    local spec = assets[name]
    if not spec then return nil end
    local material = Material(screenMix and spec.portMaterial or tint and not noFilm and spec.filmMaterial or spec.material)
    local uv = billboardKeys[name] and billboardKeys[name].keys[frame]
    local shade = tint or {1, 1, 1}
    local vertices = {}
    for _, index in ipairs(spec.triangles) do
        local v = spec.vertices[index]
        vertices[#vertices + 1] = {
            pos = Vector(v[1], v[2], v[3]),
            u = uv and uv[1] + v[4] * uv[3] or v[4],
            v = uv and uv[2] + v[5] * uv[4] or v[5],
            color = Color(math.floor(v[6] * shade[1]), math.floor(v[7] * shade[2]), math.floor(v[8] * shade[3]), v[9])
        }
    end
    local shape = Mesh(material)
    shape:BuildFromTriangles(vertices)
    cache[key] = {mesh = shape, material = material}
    return cache[key]
end

local function draw_mesh(name, frame, pos, angle, scale, alpha, tint, noFilm, screenMix)
    local entry = get_mesh(name, frame, tint, noFilm, screenMix)
    if not entry then return end
    local transform = Matrix()
    transform:Translate(pos)
    transform:Rotate(angle)
    transform:Scale(Vector(scale, scale, scale))
    cam.PushModelMatrix(transform)
    render.SetBlend(alpha or 1)
    render.SetMaterial(entry.material)
    entry.mesh:Draw()
    render.SetBlend(1)
    cam.PopModelMatrix()
end

local function sequence_frame(name, age)
    local billboard = billboardKeys[name]
    if not billboard then return 1 end
    local duration = #billboard.keys * billboard.stepTicks / 3000
    local localAge = age % duration
    return math.min(#billboard.keys, math.floor(localAge * 3000 / billboard.stepTicks) + 1)
end

local function draw_sequence()
    if not sequence then return end
    local elapsed = sequence.freezeAt or (SysTime() - sequence.start)
    local impactAge = elapsed - sequence.impactDelay
    if impactAge > 1.5 then sequence = nil return end
    local base = sequence.pos
    local size = sequence.scale
    local flat = Angle(0, 0, 0)
    local forward = sequence.direction
    local sideways = Vector(-forward.y, forward.x, 0)
    local blackPurple = {0.15, 0.04, 0.20}
    local smokeBlack = {0.025, 0.007, 0.035}
    if impactAge < 0 then
        -- Resource selection follows projectile particle graph. Emitter placement is provisional.
        local small = {
            {"2efb_amt01", -16, 0, 0.24, 0.00},
            {"2efb_amt01", 13, 9, 0.19, 0.18},
            {"2efb_amt01", 0, 0, 0.24, 0.28},
            {"2efb_amt01", -2, -13, 0.28, 0.43},
            {"2efb_amt01", 20, -7, 0.22, 0.57},
            {"2efb_amt01", -21, 11, 0.23, 0.70}
        }
        for _, item in ipairs(small) do
            local spawnTime = item[5] * sequence.impactDelay
            local age = elapsed - spawnTime
            if age >= 0 then
                local grow = math.min(1, age * 4)
                local progress = math.Clamp(age / math.max(0.01, sequence.impactDelay - spawnTime), 0, 1)
                local pos = base - forward * (110 * (1 - progress) * size)
                    + sideways * (item[2] * size) + forward * (item[3] * size)
                    + Vector(0, 0, 4 * size)
                local angle = Angle(0, EyeAngles().y + 90 + item[2] * 0.35, 90)
                draw_mesh(item[1], sequence_frame(item[1], age), pos, angle, item[4] * grow * size, 1, blackPurple, not sequence.useFilm, sequence.screenMix)
            end
        end
    else
        -- Resource selection follows impact particle graph; this is a visual staging preview.
        local burst = math.min(1, impactAge * 5)
        local fade = math.min(1, math.max(0, (1.5 - impactAge) * 2))
        -- Emitter 2 supplies the opaque atlas flame mask. Distribute several
        -- copies in depth and height so the column has a body rather than a
        -- single smooth quad; offsets remain provisional until spawn fields
        -- in the game's emitter record are decoded.
        local flameBody = {
            {-42, -16, 0, 0.78, 0.00, 0.03},
            {-16, -18, 0, 0.90, 0.02, 0.16},
            {15, -15, 0, 0.88, 0.04, 0.29},
            {42, -14, 0, 0.76, 0.07, 0.42},
            {-33, 10, 6, 0.88, 0.08, 0.12},
            {-7, 13, 3, 1.02, 0.11, 0.25},
            {24, 12, 5, 0.94, 0.13, 0.38},
            {-48, 4, 24, 0.72, 0.17, 0.06},
            {-22, -7, 31, 0.86, 0.19, 0.21},
            {7, -6, 38, 0.96, 0.21, 0.34},
            {32, 4, 29, 0.82, 0.23, 0.46},
            {-37, 15, 56, 0.70, 0.27, 0.10},
            {-11, 17, 63, 0.83, 0.29, 0.24},
            {18, 13, 58, 0.79, 0.32, 0.39},
            {38, 10, 52, 0.64, 0.35, 0.02},
            {-25, -9, 93, 0.69, 0.39, 0.17},
            {1, -12, 101, 0.76, 0.42, 0.31},
            {26, -8, 88, 0.68, 0.45, 0.44}
        }
        local darkCore = {0.095, 0.018, 0.125}
        local violetCore = {0.22, 0.065, 0.30}
        for index, item in ipairs(flameBody) do
            local age = impactAge - item[5]
            if age >= 0 then
                local pos = base + Vector(item[1] * size, item[2] * size, (item[3] + 3 + age * 9) * size)
                local angle = Angle(0, EyeAngles().y + 90 + item[1] * 0.35, 90)
                local tint = index % 4 == 0 and violetCore or darkCore
                draw_mesh("2efb_amt02", sequence_frame("2efb_amt02", age + item[6]), pos, angle, item[4] * burst * size, fade * 0.82, tint, not sequence.useFilm, false)
            end
        end
        -- Emitter 5's 08-11 geometry traces edges and detached filaments.
        -- It should surround the filled flame body instead of replacing it.
        local filaments = {
            {"2efb_amt08", -44, -12, 0.76, 0.05},
            {"2efb_amt09", 37, -11, 0.78, 0.07},
            {"2efb_amt08", -15, 8, 0.82, 0.11},
            {"2efb_amt09", 10, 13, 0.80, 0.14},
            {"2efb_amt10", -51, 18, 0.90, 0.07},
            {"2efb_amt11", 43, 17, 0.90, 0.09},
            {"2efb_amt10", -21, -17, 1.02, 0.14},
            {"2efb_amt11", 18, -19, 1.04, 0.16}
        }
        for _, item in ipairs(filaments) do
            local age = impactAge - item[5]
            if age >= 0 then
                local pos = base + Vector(item[2] * size, item[3] * size, 3 * size)
                local angle = Angle(0, EyeAngles().y + 90 + item[2] * 0.35, 90)
                draw_mesh(item[1], sequence_frame(item[1], age), pos, angle, item[4] * burst * size, fade * 0.42, blackPurple, not sequence.useFilm, false)
            end
        end
        -- Impact emitter 3 references 2efb_amt00. Its 111 vertices form a
        -- horizontal XY disk, so keep it on the ground instead of turning it
        -- upright with the flame billboards.
        local smoke = {
            {-17, 7, 3, 1.10, 0.00},
            {16, -4, 5, 1.15, 0.05},
            {-8, -10, 7, 1.00, 0.10},
            {11, 8, 9, 0.90, 0.18}
        }
        for _, item in ipairs(smoke) do
            local age = impactAge - item[5]
            if age >= 0 then
                local pos = base + Vector(item[1] * size, item[2] * size, item[3] * size)
                local angle = Angle(0, item[1] * 0.7, 0)
                draw_mesh("2efb_amt00", sequence_frame("2efb_amt00", age), pos, angle, item[4] * (1 + age * 0.25) * size, fade * 0.42, smokeBlack, true, sequence.screenMix)
            end
        end
        local fragments = {
            {"2efb_amt06", -26, -8, 61, 0.30, 0.14},
            {"2efb_amt07", 32, 7, 84, 0.25, 0.23},
            {"2efb_amt06", 5, -13, 113, 0.20, 0.33},
            {"2efb_amt07", -17, 14, 136, 0.18, 0.45}
        }
        for _, item in ipairs(fragments) do
            local age = impactAge - item[6]
            if age >= 0 then
                local pos = base + Vector(item[2] * size, item[3] * size, (item[4] + age * 65) * size)
                local angle = Angle(0, EyeAngles().y + 90 + item[2], 90)
                draw_mesh(item[1], sequence_frame(item[1], age), pos, angle, item[5] * size, fade, smokeBlack, true, sequence.screenMix)
            end
        end
        if impactAge < 0.22 then
            -- The reference frames show a brief white radial flash. Geometry/timing here await ANM decoding.
            render.SetMaterial(flashMaterial)
            local center = base + Vector(0, 0, 32 * size)
            local flashAlpha = math.floor(255 * (1 - impactAge / 0.22))
            for index = 1, 10 do
                local angle = index * math.pi * 2 / 10
                local reach = (index % 3 + 2) * 42 * size
                local target = center + Vector(math.cos(angle) * reach, math.sin(angle) * reach, (index % 2 == 0 and 1 or -0.1) * reach)
                render.DrawBeam(center, target, (index % 3 + 2) * size, 0, 1, Color(255, 255, 255, flashAlpha))
            end
        end
        if impactAge < 0.65 then
            local ringSize = (0.2 + impactAge * 1.4) * size
            draw_mesh("1efc_ring09", 1, base + Vector(0, 0, 2), flat, ringSize, (1 - impactAge / 0.65) * 0.16, blackPurple, not sequence.useFilm, sequence.screenMix)
            draw_mesh("1efc_ring13", 1, base + Vector(0, 0, 3), flat, ringSize * 0.7, (1 - impactAge / 0.65) * 0.12, blackPurple, not sequence.useFilm, sequence.screenMix)
        end
    end
end

concommand.Add("storm_amt_inspect", function(_, _, args)
    local name = args[1] or "2efb_amt00"
    if not assets[name] then
        print("Unknown Amaterasu mesh: " .. name)
        return
    end
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local trace = ply:GetEyeTrace()
    active = {
        name = name,
        frame = 1,
        pos = trace.HitPos + trace.HitNormal * 10,
        scale = math.Clamp(tonumber(args[2]) or 1, 0.01, 100),
        angle = Angle(tonumber(args[3]) or 0, tonumber(args[4]) or 0, tonumber(args[5]) or 0)
    }
    print("Inspecting original mesh " .. name .. " with temporary UnlitGeneric material")
    if billboardKeys[name] then print("Billboard UV key 1/" .. #billboardKeys[name].keys .. "; use storm_amt_frame N or storm_amt_playkeys") end
end)

concommand.Add("storm_amt_frame", function(_, _, args)
    if not active then print("Use storm_amt_inspect first") return end
    local entry = billboardKeys[active.name]
    if not entry then print("This mesh has no billboard UV keys") return end
    local keys = entry.keys
    local frame = math.Clamp(math.floor(tonumber(args[1]) or 1), 1, #keys)
    active.frame = frame
    active.playStart = nil
    print("Original billboard UV key " .. frame .. "/" .. #keys)
end)

concommand.Add("storm_amt_playkeys", function()
    if not active then print("Use storm_amt_inspect first") return end
    if not billboardKeys[active.name] then print("This mesh has no billboard UV keys") return end
    active.frame = 1
    active.playStart = SysTime()
    print("Playing original billboard UV keys at the game's 3000-tick/s time base")
end)

concommand.Add("storm_amt_hide", function() active = nil end)

concommand.Add("storm_amt_sequence", function(_, _, args)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local trace = ply:GetEyeTrace()
    local aim = ply:GetAimVector()
    local direction = Vector(aim.x, aim.y, 0)
    if direction:LengthSqr() < 0.001 then direction = Vector(1, 0, 0) end
    direction:Normalize()
    sequence = {
        pos = trace.HitPos + trace.HitNormal * 3,
        direction = direction,
        scale = math.Clamp(tonumber(args[1]) or 1, 0.05, 10),
        impactDelay = math.Clamp(tonumber(args[2]) or 1, 0.2, 2),
        useFilm = tonumber(args[3]) == 1,
        screenMix = false,
        freezeAt = tonumber(args[4]) and math.Clamp(tonumber(args[4]), 0, 3.49) or nil,
        start = SysTime()
    }
    if tonumber(args[3]) == 2 then
        print("Screenmix shader probe disabled: it only rendered brief filaments in the GMod comparison")
    end
    print("Amaterasu resource sequence preview: original meshes/textures/UV keys; emitter placement and shaders provisional")
    if sequence.freezeAt then print("Sequence held at " .. sequence.freezeAt .. " seconds from start") end
end)

concommand.Add("storm_amt_sequence_hide", function() sequence = nil end)

concommand.Add("storm_amt_version", function()
    print("Storm Amaterasu Lab " .. labVersion)
end)

hook.Add("PostDrawTranslucentRenderables", "StormAmaterasuLabMesh", function(_, skybox)
    if skybox then return end
    draw_sequence()
    if not active then return end
    if active.playStart then
        local billboard = billboardKeys[active.name]
        local ticks = (SysTime() - active.playStart) * 3000
        active.frame = math.min(#billboard.keys, math.floor(ticks / billboard.stepTicks) + 1)
        if ticks >= #billboard.keys * billboard.stepTicks then active.playStart = nil end
    end
    draw_mesh(active.name, active.frame, active.pos, active.angle, active.scale)
end)

hook.Add("ShutDown", "StormAmaterasuLabDestroy", function()
    for _, item in pairs(cache) do
        if item.mesh and item.mesh:IsValid() then item.mesh:Destroy() end
    end
end)
