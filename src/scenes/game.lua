--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, lrandom = math.floor, love.math.random

local Game = {}

local function showInventory(player)
    print('show')
    if player:getComponent(Health):isAlive() then
        Gamestate.push(Inventory(player))
    end
end

local function registerActions(player)
    local actions = {
        ['inventory']   = function() showInventory(player) end,
        ['sleep']       = function() print('try sleep player') end,
    }
    local handles = {}    

    for action, fn in pairs(actions) do
        handles[action] = Signal.register(action, fn)
    end

    return handles
end

Game.new = function()
    -- love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc' .. lrandom(1, 4))
    local player_info = PlayerInfo(player)

    local dungeon = Dungeon(player)
    dungeon:enter()

    local portrait = Portrait(player)
    local actionbar = ActionBar(player)

    local overlay = Overlay()

    local handles = registerActions(player)

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
        if key == 'i' then
            self:showInventory()
        end

        if Gamestate.current() == self and key == "escape" then
            love.event.quit()
        end
    end

    local showOverlay = function(self) overlay:fadeIn() end

    local hideOverlay = function(self) overlay:fadeOut() end

    local showInventory = function(self)
        if not player:getComponent(Health):isAlive() then return end

        Gamestate.push(Inventory(player))
    end

    local leave = function(self)
        for action, handle in ipairs(handles) do
            Signal.remove(action, handle)
            handles[action] = nil
        end

        handles = {}
    end

    return setmetatable({
        -- methods
        draw            = draw,
        leave           = leave,
        update          = update,
        keyreleased     = keyReleased,
        showOverlay     = showOverlay,
        hideOverlay     = hideOverlay,
        showInventory   = showInventory,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
