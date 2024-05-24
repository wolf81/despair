--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, lrandom = math.floor, love.math.random

local Game = {}

local CLASS_ACTIONS = {
    ['fighter'] = {  },
    ['cleric']  = { 'cast-spell', 'turn-undead', },
    ['rogue']   = { 'stealth', 'search', },
    ['mage']    = { 'cast-spell', },
}

-- actions allowed after player died
local DEATH_ACTIONS = {
    ['settings']    = true,
    ['char-sheet']  = true,
}

local function getSpells(player)
    local spells = {}

    local class = player:getComponent(Class)
    local class_name = class:getClassName()

    local type_flag = 0 
    if class_name == 'cleric' then
        type_flag = FLAGS.divine
    elseif class_name == 'mage' then
        type_flag = FLAGS.arcane
    end 

    local spell_ids = EntityFactory.getIds('spell')
    for _, spell_id in ipairs(spell_ids) do
        local flags = EntityFactory.getFlags(spell_id, 'spell')
        if FlagsHelper.hasFlag(flags, type_flag) then
            table.insert(spells, EntityFactory.create(spell_id))
        end
    end

    return spells
end

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

local function onChangeLevel(player, level_idx) Gamestate.push(ChangeLevel(player, level_idx)) end

local function onSleepPlayer(player, level) 
    if level:getScheduler():inCombat() then
        return Signal.emit('notify', 'Can\'t sleep while enemies are nearby')
    end

    Gamestate.push(Sleep(player)) 
end

local function onShowInventory(player) Gamestate.push(Inventory(player)) end

local function onShowCharacterSheet(player) 
    if player:getComponent(Class):canLevelUp() then
        Gamestate.push(LevelUp(player))
    else
        Gamestate.push(CharSheet(player)) 
    end
end

local function getLeftActionButtons(player)
    local buttons = {}

    table.insert(buttons, UI.makeButton('swap-weapon'))

    local class_name = player:getComponent(Class):getClassName()

    for _, action in ipairs(CLASS_ACTIONS[class_name]) do
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

Game.new = function(level_info, player_id)
    -- love.math.setRandomSeed(5)
    local player = EntityFactory.create(player_id or 'pc' .. lrandom(1, 4))

    local status_panel = StatusPanel(player)

    local backpack = player:getComponent(Backpack)

    local dungeon = Dungeon(level_info, player)
    dungeon:enter()

    local notify_bar = NotifyBar()

    -- handles for observer pattern with Signal, added on enter, removed on leave
    local handles = {}

    local item_bar = nil

    local portrait = player:getComponent(PC):getPortrait():getImage()
    local portrait_w = portrait:getDimensions()

    local HALF_W = mfloor((WINDOW_W - STATUS_PANEL_W - portrait_w) / 2)

    local char_sheet_button = UI.makeButton('char-sheet', portrait)

    -- configure layout
    local layout = tidy.HStack({
        tidy.VStack({
            UI.makeView(dungeon, tidy.Stretch(1)),
            tidy.HStack(tidy.MinSize(0, ACTION_BAR_H), {
                tidy.HStack(getLeftActionButtons(player), tidy.MinSize(HALF_W, 0)),
                char_sheet_button,
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
    }):setFrame(0, 0, WINDOW_W, WINDOW_H)

    local update = function(self, dt) 
        for e in layout:eachElement() do
            e.widget:update(dt)
        end

        notify_bar:update(dt)
    end

    local draw = function(self) 
        for e in layout:eachElement() do
            e.widget:draw()
        end

        if item_bar then item_bar:draw() end

        notify_bar:draw()
    end

    local onShowItems = function(items, action)
        if #items == 0 then return print('empty item list') end

        Gamestate.push(ChooseItem(player, items, getActionButton(layout, action)))
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
        -- calculate item totals in inventory
        local food_count, wand_count, tome_count, potion_count = 0, 0, 0, 0

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

        -- enable buttons if item totals are greater than 0
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

    local onNotify = function(message, duration)
        notify_bar:show(message, duration)
    end

    local onLevelUp = function(entity)
        local pc, class = entity:getComponent(PC), entity:getComponent(Class)
        if pc and class then
            pc:getPortrait():setShowLevelUp(class:canLevelUp())
            char_sheet_button.widget:setImage(pc:getPortrait():getImage())
        end
    end

    local enter = function(self, from)
        local handlers = {
            ['sleep']           = function() onSleepPlayer(player, dungeon:getLevel()) end,
            ['inventory']       = function() onShowInventory(player) end,
            ['char-sheet']      = function() onShowCharacterSheet(player) end,
            ['take']            = function() onInventoryChanged(player) end,
            ['put']             = function() onInventoryChanged(player) end,
            ['cast-spell']      = function() onShowItems(getSpells(player), 'cast-spell') end,
            ['use-food']        = function() onShowItems(getItems(player, 'food'), 'use-food') end,
            ['use-wand']        = function() onShowItems(getItems(player, 'wand'), 'use-wand') end,
            ['use-scroll']      = function() onShowItems(getItems(player, 'tome'), 'use-scroll') end,
            ['use-potion']      = function() onShowItems(getItems(player, 'potion'), 'use-potion') end,
            ['destroy']         = function(...) onDestroy(...) end,
            ['change-level']    = function(...) onChangeLevel(...) end,
            ['notify']          = function(...) onNotify(...) end,
            ['level-up']        = function(...) onLevelUp(...) end,
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

    local keyReleased = function(self, key, scancode)        
        if key == 'i' then Signal.emit('inventory') end

        if Gamestate.current() == self and key == 'escape' then
            love.event.quit()
        end
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
        mouseReleased       = mouseReleased,
        setActionsEnabled   = setActionsEnabled,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
