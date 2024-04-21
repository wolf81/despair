local Sleep = {}

local FADE_DURATION = 0.5

Sleep.new = function(player)
    -- recover health over time (turns)
    local health = player:getComponent(Health)
    assert(health ~= nil, 'missing component: "Health"')

    local game = nil

    local background = {
        texture = TextureGenerator.generateColorTexture(
            WINDOW_W - STATUS_PANEL_W, 
            WINDOW_H - ACTION_BAR_H, 
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
        Timer.tween(FADE_DURATION, background, { alpha = 1.0 }, 'linear', function() 
            Timer.after(FADE_DURATION, function() 
                -- start 'exit sleep' animation
                Timer.tween(1.0, background, { alpha = 0.0 }, 'linear', function() 
                    Gamestate.pop()
                end)
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
