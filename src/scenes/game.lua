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
        -- prevent an isssue in which a single black frame is shown by immediately calling update
        Gamestate.update(0)
    end
end

local function showCharacterSheet(player)
    if player:getComponent(Health):isAlive() then
        Gamestate.push(CharSheet(player))
        -- prevent an isssue in which a single black frame is shown by immediately calling update
        Gamestate.update(0)
    end
end

local function showSelectWandMenu(player)
    -- 1. find all wands in player backpack
    -- 2. select wand button
    -- 3. show all wands in menu
    -- (menu might be disabled if no wands found?) 
end

local function registerActions(player, game)
    local actions = {
        ['char-sheet']  = function() showCharacterSheet(player) end,
        ['inventory']   = function() showInventory(player) end,
        ['sleep']       = function() print('try sleep player') end,
        ['use-wand']    = function() game:showWands() end,
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

    table.insert(buttons, UI.makeFlexPanel())

    return buttons
end

local function getRightActionButtons()
    local buttons = {}

    table.insert(buttons, UI.makeFlexPanel())

    for _, action in ipairs({ 'use-potion', 'use-wand', 'use-scroll' }) do
        table.insert(buttons, UI.makeButton(action))
    end

    return buttons
end

local function getWands(backpack)
    local wands = {}

    for idx = 1, backpack:getSize() do
        local item = backpack:peek(idx)
        print(idx, item.type)
        if item.type == 'wand' then
            table.insert(wands, item)
        end
    end

    return wands
end

local function getActionBarButton(layout, action)
    for e in layout:eachElement() do
        if getmetatable(e.widget) == ActionBarButton then
            if e.widget:getAction() == action then
                return e.widget
            end
        end
    end

    return nil
end

Game.new = function()
    -- love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc' .. lrandom(1, 4))
    local player_info = PlayerInfo(player)

    local backpack = player:getComponent(Backpack)

    local dungeon = Dungeon(player)
    dungeon:enter()

    local portrait = Portrait(player)

    local overlay = Overlay()

    local handles = {}

    local portrait_w = portrait:getSize()

    local item_bar = nil

    local HALF_W = mfloor((WINDOW_W - INFO_PANEL_W - portrait_w) / 2)

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

        if item_bar then item_bar:draw() end

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
        -- prevent an isssue in which a single black frame is shown by immediately calling update
        Gamestate.update(0)
    end

    local showWands = function(self)
        local wands = getWands(backpack)

        if #wands == 0 then return print('no wands in backpack') end

        local button = getActionBarButton(layout, 'use-wand')
        print('btn', button)

        if player:getComponent(Health):isAlive() then
            Gamestate.push(ChooseItem(player, wands, button))
            -- prevent an isssue in which a single black frame is shown by immediately calling update
            Gamestate.update(0)
        end
    end

    local enter = function(self, from)
        handles = registerActions(player, self)
    end

    local leave = function(self, to)
        for action, handle in ipairs(handles) do
            Signal.remove(action, handle)
            handles[action] = nil
        end

        handles = {}
    end

    return setmetatable({
        -- methods
        draw            = draw,
        enter           = enter,
        leave           = leave,
        update          = update,
        showWands       = showWands,
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
