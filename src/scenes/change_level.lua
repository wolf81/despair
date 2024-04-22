--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local ChangeLevel = {}

local FADE_DURATION = 0.5

local function newBackgroundImage()
    local canvas = love.graphics.newCanvas(WINDOW_W, WINDOW_H)

    local w = WINDOW_W - STATUS_PANEL_W
    local h = WINDOW_H - ACTION_BAR_H

    -- reveal the tile area of PC
    local x1 = (w - TILE_SIZE) / 2
    local x2 = x1 + TILE_SIZE
    local y1 = (h - TILE_SIZE) / 2
    local y2 = y1 + TILE_SIZE
    
    canvas:renderTo(function()
        love.graphics.setColor(0.0, 0.0, 0.0, 1.0)

        love.graphics.rectangle('fill', 0, y1, x1, y2 - y1)
        love.graphics.rectangle('fill', x2, y1, w - x2, y2 - y1)
        love.graphics.rectangle('fill', 0, 0, w, y1)
        love.graphics.rectangle('fill', 0, y2, w, h - y2)
    end)

    return canvas
end

ChangeLevel.new = function(player, level_idx)
    local game = nil

    local background = {
        texture = newBackgroundImage(),
        alpha = 0.0,
    }

    local update = function(self, dt)
        game:update(dt)
    end

    local draw = function(self)
        game:draw()

        love.graphics.setColor(1.0, 1.0, 1.0, background.alpha)
        love.graphics.draw(background.texture, 0, 0)
    end

    local enter = function(self, from)
        game = from

        game:setActionsEnabled(false)
        player:getComponent(Control):setEnabled(false)
        Timer.after(ANIM_DURATION, function() 
            Timer.tween(FADE_DURATION, background, { alpha = 1.0 }, 'linear', function()
                game:getDungeon():setLevel(level_idx)
                Timer.tween(FADE_DURATION, background, { alpha = 0.0 }, 'linear', function()
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
    }, ChangeLevel)
end

return setmetatable(ChangeLevel, {
    __call = function(_, ...) return ChangeLevel.new(...) end,
})
