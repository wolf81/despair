--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Overlay = {}

local FADE_DURATION = 0.2
local MAX_ALPHA = 0.6

Overlay.new = function()
    local handle = nil

    local draw = function(self)
        love.graphics.setColor(0.0, 0.0, 0.0, self.alpha)
        love.graphics.rectangle('fill', 0, 0, WINDOW_W, WINDOW_H)
    end

    local fadeIn = function(self)
        if handle then Timer.cancel(handle) end

        handle = Timer.tween(FADE_DURATION, self, { alpha = MAX_ALPHA }, 'linear', function()
            self.alpha = MAX_ALPHA
            handle = nil
        end)
    end

    local fadeOut = function(self)
        if handle then Timer.cancel(handle) end

        handle = Timer.tween(FADE_DURATION, self, { alpha = 0.0 }, 'linear', function()
            self.alpha = 0.0
            handle = nil
        end)
    end

    return setmetatable({
        -- properties
        alpha   = 0.0,
        -- methods
        draw    = draw,
        fadeIn  = fadeIn,
        fadeOut = fadeOut,
    }, Overlay)
end

return setmetatable(Overlay, {
    __call = function(_, ...) return Overlay.new(...) end,
})
