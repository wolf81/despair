--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, lrandom = math.floor, love.math.random

local Game = {}

local CLASS_ACTIONS = {
    ['fighter'] = {  },
    ['cleric']  = { 'turn-undead', 'cast-spell', },
    ['rogue']   = { 'stealth', 'search',  },
    ['mage']    = { 'cast-spell', },
}

local function showInventory(player)
    if player:getComponent(Health):isAlive() then
        Gamestate.push(Inventory(player))
    end
end

local function showCharacterSheet(player)
    if player:getComponent(Health):isAlive() then
        Gamestate.push(CharSheet(player))
    end
end

local function registerActions(player)
    local actions = {
        ['char-sheet']  = function() showCharacterSheet(player) end,
        ['inventory']   = function() showInventory(player) end,
        ['sleep']       = function() print('try sleep player') end,
    }
    local handles = {}    

    for action, fn in pairs(actions) do
        handles[action] = Signal.register(action, fn)
    end

    return handles
end

local function getLeftActionButtons(player)
    local buttons = {}

    table.insert(buttons, UI.makeButton('swap-weapon'))

    for _, action in ipairs(CLASS_ACTIONS[player.class]) do
        table.insert(buttons, UI.makeButton(action))
    end

    table.insert(buttons, UI.makeFlex())

    return buttons
end

local function getRightActionButtons()
    local buttons = {}

    table.insert(buttons, UI.makeFlex())

    for _, action in ipairs({ 'use-potion', 'use-wand', 'use-scroll' }) do
        table.insert(buttons, UI.makeButton(action))
    end

    return buttons
end

Game.new = function()
    -- love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc' .. lrandom(1, 4))
    local player_info = PlayerInfo(player)

    local dungeon = Dungeon(player)
    dungeon:enter()

    local portrait = Portrait(player)

    local overlay = Overlay()

    local handles = registerActions(player)

    local HALF_W = (WINDOW_W - INFO_PANEL_W - 50) / 2
    
    -- configure layout
    local layout = tidy.HStack({
        tidy.VStack(tidy.Stretch(1), {
            UI.makeView(dungeon, tidy.Stretch(1)),
            tidy.HStack({
                tidy.HStack(getLeftActionButtons(player), tidy.MinSize(HALF_W, 0)),
                UI.makeButton('char-sheet', portrait:getImage()),
                tidy.HStack(getRightActionButtons(), tidy.MinSize(HALF_W, 0)),
            }),
        }),
        tidy.VStack({
            UI.makeView(player_info, tidy.MinSize(INFO_PANEL_W, WINDOW_H - 50)),
            tidy.HStack({
                UI.makeButton('sleep'),
                UI.makeButton('inventory'),
                UI.makeButton('settings'),
            })
        })
    })
    layout:setFrame(0, 0, WINDOW_W, WINDOW_H)
    for e in layout:eachElement() do
        e.widget:setFrame(e.rect:unpack())
    end

    local update = function(self, dt) 
        for e in layout:eachElement() do
            e.widget:update(dt)
        end
    end

    local draw = function(self) 
        for e in layout:eachElement() do
            e.widget:draw()
        end

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
        mouseMoved      = mouseMoved,
        keyReleased     = keyReleased,
        showOverlay     = showOverlay,
        hideOverlay     = hideOverlay,
        showInventory   = showInventory,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
