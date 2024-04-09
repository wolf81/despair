--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, lrandom = math.floor, love.math.random

local Game = {}

Game.new = function()
    love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc' .. lrandom(1, 4))
    local player_info = PlayerInfo(player)

    local dungeon = Dungeon(player)
    dungeon:enter()

    local is_paused, show_inventory = false, false

    local inventory = Inventory(player)

    local portrait = Portrait()

    local update = function(self, dt) 
        if (not is_paused) and (not show_inventory) then
            dungeon:update(dt)
        end

        if show_inventory then
            inventory:update(dt)
        end

        player_info:update(dt)
    end

    local player_info_w = INFO_PANEL_WIDTH

    local draw = function(self) 
        love.graphics.push()
        love.graphics.scale(SCALE)

        dungeon:draw(0, 0, WINDOW_W - player_info_w, WINDOW_H) 

        love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
        love.graphics.rectangle('fill', WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        player_info:draw(WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        if show_inventory then
            local inv_w, inv_h = inventory:getSize()
            local inv_x = mfloor((WINDOW_W - player_info_w - inv_w) / 2)
            local inv_y = mfloor((WINDOW_H - inv_h) / 2)
            inventory:draw(inv_x, inv_y, inv_w, inv_h)
        end

        if is_paused then
            love.graphics.setFont(FONT)

            local text_w = FONT:getWidth('PAUSED')
            local text_x = WINDOW_W - text_w - 25
            local text_y = WINDOW_H - 30
            local text_h = FONT:getHeight()

            love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
            love.graphics.rectangle('fill', text_x - 5, text_y - 5, text_w + 10, text_h + 5 * 2)
 
            love.graphics.setLineWidth(1.0)
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            love.graphics.rectangle('line', text_x - 5.5, text_y - 5.5, text_w + 10, text_h + 5 * 2)

            love.graphics.printf('PAUSED', text_x, text_y, text_w, 'left')
        end

        love.graphics.pop()
    end

    local keyPressed = function(self, key, scancode)
        if key == 'space' then is_paused = (not is_paused) end
        if key == 'i' then show_inventory = (not show_inventory) end
    end

    return setmetatable({
        -- methods
        update          = update,
        draw            = draw,
        keyPressed      = keyPressed,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
