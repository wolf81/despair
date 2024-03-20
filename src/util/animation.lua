--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmin = math.min

local DURATION = 0.5

local Animation = {}

function Animation.loop(frames, duration)
    local frame_idx = 1
    local time = 0.0
    local duration = duration or DURATION

    local update = function(self, dt)
        time = time + dt

        if time > duration then
            time = 0
            frame_idx = (frame_idx % #frames) + 1
        end
    end

    local draw = function(self, texture, quads, pos)
        local frame = frames[frame_idx]
        local quad = quads[frame]
        love.graphics.draw(texture, quad, pos.x, pos.y)
    end

    return setmetatable({ 
        -- methods
        update  = update,
        draw    = draw,
    }, Animation)
end

function Animation.crossfade(frame1, frame2, duration)
    local time = 0.0
    local duration = duration or DURATION

    local update = function(self, dt)
        time = mmin(time + dt, duration)
    end

    local draw = function(self, texture, quads, pos)
        local alpha = time / duration

        local quad = quads[frame1]
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0 - alpha)
        love.graphics.draw(texture, quad, pos.x, pos.y)

        quad = quads[frame2]
        love.graphics.setColor(1.0, 1.0, 1.0, alpha)
        love.graphics.draw(texture, quad, pos.x, pos.y)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    return setmetatable({ 
        -- methods
        update  = update,
        draw    = draw,
    }, Animation)
end

return setmetatable(Animation, {})
