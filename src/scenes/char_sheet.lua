local CharSheet = {}

CharSheet.new = function()
    local background = TextureGenerator.generatePaperTexture(600, 300)
    local background_w, background_h = background:getDimensions()

    local game = nil

    local update = function(self, dt) 
        game:update(dt)
    end

    local draw = function(self)
        game:draw()

        local x = (WINDOW_W - background_w) / 2
        local y = (WINDOW_H - background_h) / 2

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)
    end

    local enter = function(self, from)
        game = from
        game:showOverlay()
    end

    local leave = function(self, to)
        game:hideOverlay()
        game = nil
    end

    local keyReleased = function(self, key, scancode)
        if key == "escape" then
            Gamestate.pop()
        end
    end

    return setmetatable({
        -- methods
        keyreleased = keyReleased,
        update      = update,
        enter       = enter,
        leave       = leave,
        draw        = draw,
    }, CharSheet)
end

return setmetatable(CharSheet, {
    __call = function(_, ...) return CharSheet.new(...) end,
})
