local ChangeLevel = {}

local function newBackgroundImage()
    local canvas = love.graphics.newCanvas(WINDOW_W, WINDOW_H)

    local x1 = (WINDOW_W - STATUS_PANEL_W - 48) / 2
    local x2 = x1 + 48
    local y1 = (WINDOW_H - ACTION_BAR_H - 48) / 2
    local y2 = y1 + 48
    
    canvas:renderTo(function()
        love.graphics.setColor(0.0, 0.0, 0.0, 1.0)

        love.graphics.rectangle('fill', 0, y1, x1, y2 - y1)
        love.graphics.rectangle('fill', x2, y1, WINDOW_W - x2, y2 - y1)
        love.graphics.rectangle('fill', 0, 0, WINDOW_W, y1)
        love.graphics.rectangle('fill', 0, y2, WINDOW_W, WINDOW_H - y2)
    end)

    return canvas
end

ChangeLevel.new = function(player, level_idx)
    local game = nil

    local background = {
        texture = newBackgroundImage(),
        alpha = 0.0,
    }

    -- TODO:
    -- 1. darken all area around player, keep player visible
    -- 2. change level
    -- 3. lighten up area around player

    local update = function(self, dt)
        game:update(dt)
    end

    local draw = function(self)
        game:draw()

        love.graphics.setColor(1.0, 1.0, 1.0, background.alpha)
        love.graphics.draw(background.texture, 0, 0)
    end

    local enter = function(self, from)
        print('ENTER CHANGE LEVEL')
        game = from

        game:setActionsEnabled(false)
        player:getComponent(Control):setEnabled(false)

        Timer.tween(0.5, background, { alpha = 1.0 }, 'linear', function()
            print('change level', level_idx)
            game:getDungeon():setLevel(level_idx)

            Timer.tween(0.5, background, { alpha = 0.0 }, 'linear', function()
                Gamestate.pop()            
            end)
        end)
    end

    local leave = function(self, to)
        print('LEAVE CHANGE LEVEL')

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
    }, ChangeLevel)
end

return setmetatable(ChangeLevel, {
    __call = function(_, ...) return ChangeLevel.new(...) end,
})
