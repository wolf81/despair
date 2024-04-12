--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, lrandom = math.floor, love.math.random

local Game = {}

local function showInventory()
end

Game.new = function()
    -- love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc' .. lrandom(1, 4))
    local player_info = PlayerInfo(player)

    local dungeon = Dungeon(player)
    dungeon:enter()

    local portrait = Portrait(player)
    local actionbar = ActionBar(player)
    local actionbar_w, actionbar_h = actionbar:getSize()

    local overlay = Overlay()

    local update = function(self, dt) 
        dungeon:update(dt)

        actionbar:update(dt)

        player_info:update(dt)
    end

    local draw = function(self) 
        dungeon:draw(0, 0, WINDOW_W - INFO_PANEL_W, WINDOW_H - ACTION_BAR_H) 

        player_info:draw(WINDOW_W - INFO_PANEL_W, 1, INFO_PANEL_W, WINDOW_H - ACTION_BAR_H)

        actionbar:draw(0, WINDOW_H - ACTION_BAR_H - 1)

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

    local leave = function(self, to)
        Signal.remove(self)
    end

    local showOverlay = function(self) overlay:fadeIn() end

    local hideOverlay = function(self) overlay:fadeOut() end

    return setmetatable({
        -- methods
        draw        = draw,
        leave       = leave,
        update      = update,
        keyreleased = keyReleased,
        showOverlay = showOverlay,
        hideOverlay = hideOverlay,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
