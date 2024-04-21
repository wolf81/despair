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
    ['cleric']  = { 'cast-spell', 'turn-undead', },
    ['rogue']   = { 'stealth', 'search',  },
    ['mage']    = { 'cast-spell', },
}

-- actions allowed after player died
local DEATH_ACTIONS = {
    ['settings']    = true,
    ['char-sheet']  = true,
}

local function getItems(player, type)
    local backpack = player:getComponent(Backpack)

    local items = {}
    local item_info = {}

    for idx = 1, backpack:getSize() do
        local item = backpack:peek(idx)
        -- only show unique item types, to prevent showing 2 wands of frost, 3 tomes of identify, ...
        -- TODO: maybe show item count in button (?)
        if item.type == type and not item_info[item.id] then
            table.insert(items, item)
            item_info[item.id] = item
        end
    end

    return items
end

local function changeLevel(player, level_idx) Gamestate.push(ChangeLevel(player, level_idx)) end

local function sleepPlayer(player) Gamestate.push(Sleep(player)) end

local function showInventory(player) Gamestate.push(Inventory(player)) end

local function showCharacterSheet(player) Gamestate.push(CharSheet(player)) end

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

    for _, action in ipairs({ 'use-food', 'use-potion', 'use-wand', 'use-scroll' }) do
        table.insert(buttons, UI.makeButton(action))
    end

    return buttons
end

local function getActionButton(layout, action)
    for e in layout:eachElement() do
        if getmetatable(e.widget) == ActionButton then
            if e.widget:getAction() == action then
                return e.widget
            end
        end
    end

    return nil
end

Game.new = function()
    -- love.math.setRandomSeed(5)

    local player = EntityFactory.create('pc' .. lrandom(1, 4))
    local status_panel = StatusPanel(player)

    local backpack = player:getComponent(Backpack)

    local dungeon = Dungeon(player)
    dungeon:enter()

    -- a semi-transparent overlay, used when showing char-sheet, inventory on top ...
    local overlay = Overlay()

    -- handles for observer pattern with Signal, added on enter, removed on leave
    local handles = {}

    local item_bar = nil

    local portrait = PortraitGenerator.generate(player)
    local portrait_w = portrait:getDimensions()

    local HALF_W = mfloor((WINDOW_W - STATUS_PANEL_W - portrait_w) / 2)

    -- configure layout
    local layout = tidy.HStack({
        tidy.VStack({
            UI.makeView(dungeon, tidy.Stretch(1)),
            tidy.HStack(tidy.MinSize(0, ACTION_BAR_H), {
                tidy.HStack(getLeftActionButtons(player), tidy.MinSize(HALF_W, 0)),
                UI.makeButton('char-sheet', portrait),
                tidy.HStack(getRightActionButtons(), tidy.MinSize(HALF_W, 0)),
            }),
        }),
        tidy.VStack({
            UI.makeView(status_panel, tidy.MinSize(STATUS_PANEL_W, 0), tidy.Stretch(0, 1)),
            tidy.HStack(tidy.MinSize(0, ACTION_BAR_H), {
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
        if key == 'i' then showInventory(player) end

        if Gamestate.current() == self and key == 'escape' then
            love.event.quit()
        end
    end

    local showOverlay = function(self) overlay:fadeIn() end

    local hideOverlay = function(self) overlay:fadeOut() end

    local showItems = function(items, action)
        if #items == 0 then return print('empty item list') end

        local button = getActionButton(layout, action)
        Gamestate.push(ChooseItem(player, items, button))
    end

    local function onDestroy(entity, duration)
        if entity.type ~= 'pc' then return end
        
        -- ensure player can use mouse to interact with UI after death
        love.mouse.setVisible(true) 

        -- on player death, disable most actions, as it doesn't make sense if player can use 
        -- scrolls, wands, cast spells or enter stealth mode
        for element in layout:eachElement() do
            if getmetatable(element.widget) == ActionButton then
                local button = element.widget
                if not DEATH_ACTIONS[button:getAction()] then
                    button:setEnabled(false)
                end
            end
        end
    end

    local onInventoryChanged = function(player)
        local food_count = 0
        local wand_count = 0
        local tome_count = 0
        local potion_count = 0

        for idx = 1, backpack:getSize() do
            local item = backpack:peek(idx)            
            if item.type == 'potion' then
                potion_count = potion_count + 1
            elseif item.type == 'wand' then
                wand_count = wand_count + 1
            elseif item.type == 'tome' then
                tome_count = tome_count + 1                
            elseif item.type == 'food' then
                food_count = food_count + 1
            end
        end

        for element in layout:eachElement() do
            if getmetatable(element.widget) == ActionButton then
                local button = element.widget
                local action = button:getAction()

                if action == 'use-wand' then
                    button:setEnabled(wand_count > 0)
                elseif action == 'use-scroll' then
                    button:setEnabled(tome_count > 0)
                elseif action == 'use-potion' then
                    button:setEnabled(potion_count > 0)
                elseif action == 'use-food' then
                    button:setEnabled(food_count > 0)
                end
            end
        end        
    end

    local enter = function(self, from)
        local handlers = {
            ['sleep']           = function() sleepPlayer(player) end,
            ['inventory']       = function() showInventory(player) end,
            ['char-sheet']      = function() showCharacterSheet(player) end,
            ['change-level']    = function(...) changeLevel(...) end,
            ['take']            = function() onInventoryChanged(player) end,
            ['put']             = function() onInventoryChanged(player) end,
            ['use-food']        = function() showItems(getItems(player, 'food'), 'use-food') end,
            ['use-wand']        = function() showItems(getItems(player, 'wand'), 'use-wand') end,
            ['use-scroll']      = function() showItems(getItems(player, 'tome'), 'use-scroll') end,
            ['use-potion']      = function() showItems(getItems(player, 'potion'), 'use-potion') end,
            ['destroy']         = function(...) onDestroy(...) end,
        }
        for action, handler in pairs(handlers) do
            handles[action] = Signal.register(action, handler)
        end
    end

    local leave = function(self, to)
        for action, handle in ipairs(handles) do
            Signal.remove(action, handle)
            handles[action] = nil
        end

        handles = {}
    end

    local setActionsEnabled = function(self, flag)
        local enabled = flag == true

        -- enable / disable all buttons
        for element in layout:eachElement() do
            local widget_type = getmetatable(element.widget)
            if widget_type == ActionButton or widget_type == ImageButton then
                element.widget:setEnabled(enabled)
            end
        end

        -- update use buttons for inventory state
        if enabled then onInventoryChanged(self) end
    end

    local getDungeon = function(self) return dungeon end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        love.mouse.setVisible(true) 
    end

    -- set initial state for "use" buttons, e.g. enable wand button if we have at least 1 wand
    onInventoryChanged(nil)

    return setmetatable({
        -- methods
        draw                = draw,
        leave               = leave,
        enter               = enter,
        leave               = leave,
        update              = update,
        getDungeon          = getDungeon,
        keyReleased         = keyReleased,
        showOverlay         = showOverlay,
        hideOverlay         = hideOverlay,
        mouseReleased       = mouseReleased,
        setActionsEnabled   = setActionsEnabled,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
