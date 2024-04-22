--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Overlay = {}

local FADE_DURATION = 0.2

Overlay.new = function()
    local handle = nil

    local background = {
        texture = TextureGenerator.generateColorTexture(WINDOW_W, WINDOW_H, { 0.0, 0.0, 0.0, 0.5 }),
        alpha = 0.0,
    }

    local draw = function(self)
        love.graphics.setColor(0.0, 0.0, 0.0, background.alpha)
        love.graphics.draw(background.texture, 0, 0)
    end

    local fadeIn = function(self)
        if handle then Timer.cancel(handle) end

        handle = Timer.tween(FADE_DURATION, background, { alpha = 1.0 }, 'linear', function()
            background.alpha = 1.0
            handle = nil
        end)
    end

    local fadeOut = function(self)
        if handle then Timer.cancel(handle) end

        handle = Timer.tween(FADE_DURATION, background, { alpha = 0.0 }, 'linear', function()
            background.alpha = 0.0
            handle = nil
        end)
    end

    return setmetatable({
        -- methods
        draw    = draw,
        fadeIn  = fadeIn,
        fadeOut = fadeOut,
    }, Overlay)
end

return setmetatable(Overlay, {
    __call = function(_, ...) return Overlay.new(...) end,
})
