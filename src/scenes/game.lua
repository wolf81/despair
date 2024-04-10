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

    local portrait = Portrait()

    local overlay = Overlay()

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
        dungeon:draw(0, 0, WINDOW_W - player_info_w, WINDOW_H) 

        love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
        love.graphics.rectangle('fill', WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        player_info:draw(WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        overlay:draw()
    end

    local keyPressed = function(self, key, scancode)        
        if key == 'i' and player:getComponent(Health):isAlive() then
            Gamestate.push(Inventory(player))
        end
    end

    local showOverlay = function(self) overlay:fadeIn() end

    local hideOverlay = function(self) overlay:fadeOut() end

    return setmetatable({
        -- methods
        draw            = draw,
        update          = update,
        keypressed      = keyPressed,
        showOverlay     = showOverlay,
        hideOverlay     = hideOverlay,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
