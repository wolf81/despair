--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, lrandom = math.floor, love.math.random

local Game = {}

Game.new = function()
    -- love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc' .. lrandom(1, 4))
    local player_info = PlayerInfo(player)

    local dungeon = Dungeon(player)
    dungeon:enter()

    local portrait = Portrait(player)
    local actionbar = Actionbar(player)
    local actionbar_w, actionbar_h = actionbar:getSize()

    local overlay = Overlay()

    local update = function(self, dt) 
        dungeon:update(dt)

        player_info:update(dt)
    end

    local player_info_w = INFO_PANEL_WIDTH

    local draw = function(self) 
        dungeon:draw(0, 0, WINDOW_W - player_info_w, WINDOW_H) 

        love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
        love.graphics.rectangle('fill', WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        player_info:draw(WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        actionbar:draw((WINDOW_W - player_info_w - actionbar_w) / 2, WINDOW_H - actionbar_h)

        overlay:draw()
    end

    local keyReleased = function(self, key, scancode)        
        if key == 'i' and player:getComponent(Health):isAlive() then
            Gamestate.push(Inventory(player))
        end

        if Gamestate.current() == self and key == "escape" then
            love.event.quit()
        end
    end

    local showOverlay = function(self) overlay:fadeIn() end

    local hideOverlay = function(self) overlay:fadeOut() end

    return setmetatable({
        -- methods
        draw            = draw,
        update          = update,
        keyreleased     = keyReleased,
        showOverlay     = showOverlay,
        hideOverlay     = hideOverlay,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
