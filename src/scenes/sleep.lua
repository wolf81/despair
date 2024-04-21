local Sleep = {}

Sleep.new = function(player)
    local game = nil

    local background = {
        texture = TextureGenerator.generateColorTexture(
            WINDOW_W, 
            WINDOW_H, 
            { 0.0, 0.0, 0.0, 1.0 }),
        alpha = 0.0,
    }

    local draw = function(self)
        game:draw()

        love.graphics.setColor(1.0, 1.0, 1.0, background.alpha)
        love.graphics.draw(background.texture)
    end

    local update = function(self, dt)
        game:update(dt)
    end

    local enter = function(self, from)
        game = from

        player:getComponent(Control):setEnabled(false)
        game:setActionsEnabled(false)

        -- start 'enter sleep' animation
        Timer.tween(1.0, background, { alpha = 1.0 }, 'linear', function() end)

        Timer.after(1.0, function() 
            -- start 'exit sleep' animation
            Timer.tween(1.0, background, { alpha = 0.0 }, 'linear', function() 
                Gamestate.pop()
            end)
        end)
    end

    local leave = function(self, to)
        player:getComponent(Control):setEnabled(true)
        game:setActionsEnabled(true)

        game = nil
    end

    return setmetatable({
        -- methods
        draw    = draw,
        enter   = enter,
        leave   = leave,
        update  = update,
    }, Sleep)
end

return setmetatable(Sleep, {
    __call = function(_, ...) return Sleep.new(...) end,
})
