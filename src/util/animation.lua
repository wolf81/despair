--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmin, mmax = math.min, math.max

local Animation = {}

Animation.new = function(frames, duration)
    assert(duration ~= nil, 'missing parameter "duration"')

    local frame_idx = 1
    local time = 0.0

    local update = function(self, dt)
        time = time + dt

        if time > duration then
            time = 0
            frame_idx = (frame_idx % #frames) + 1
        end
    end

    local draw = function(self, texture, quads, pos, rot, ox, oy)
        local frame = frames[frame_idx]
        local quad = quads[frame]
        love.graphics.draw(texture, quad, pos.x, pos.y, rot, 1, 1, ox, oy)
    end

    return setmetatable({ 
        -- methods
        update  = update,
        draw    = draw,
    }, Animation)
end

return setmetatable(Animation, {
    __call = function(_, ...) return Animation.new(...) end,
})
