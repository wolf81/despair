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

local function getItems(player, type)
    local backpack = player:getComponent(Backpack)

    local items = {}

    for idx = 1, backpack:getSize() do
        local item = backpack:peek(idx)
        if item.type == type then
            table.insert(items, item)
        end
    end

    return items
end

local function showInventory(player)
    Gamestate.push(Inventory(player))
    -- prevent an isssue in which a single black frame is shown by immediately calling update
    Gamestate.update(0)
end

local function showCharacterSheet(player)
    Gamestate.push(CharSheet(player))
    -- prevent an isssue in which a single black frame is shown by immediately calling update
    Gamestate.update(0)
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

    -- handles for observer pattern with Signal, added on enter, removed on leave
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
        Gamestate.push(Inventory(player))
        -- prevent an isssue in which a single black frame is shown by immediately calling update
        Gamestate.update(0)
    end

    local showItems = function(items, action)
        if #items == 0 then return print('empty item list') end

        local button = getActionBarButton(layout, action)
        Gamestate.push(ChooseItem(player, items, button))
        -- prevent an isssue in which a single black frame is shown by immediately calling update
        Gamestate.update(0)
    end

    local function onDestroy(entity, duration)
        if entity.type ~= 'pc' then return end
        
        -- ensure player can use mouse to interact with UI after death
        love.mouse.setVisible(true) 

        -- on player death, disable most actions
        local enabled_actions = {
            ['profile'] = true,
            ['settings'] = true,
        }

        for element in layout:eachElement() do
            if getmetatable(element.widget) == ActionBarButton then
                local button = element.widget
                if not enabled_actions[button:getAction()] then
                    button:setEnabled(false)
                end
            end
        end
    end

    local onInventoryChanged = function(player)
        local wand_count = 0
        local tome_count = 0
        local potion_count = 0

        for idx = 1, backpack:getSize() do
            local item = backpack:peek(idx)
            if item.type == 'wand' then
                wand_count = wand_count + 1
            elseif item.type == 'tome' then
                tome_count = tome_count + 1
            elseif item.type == 'scroll' then
                scroll_count = scroll_count + 1
            end
        end

        for element in layout:eachElement() do
            if getmetatable(element.widget) == ActionBarButton then
                local button = element.widget
                local action = button:getAction()

                if action == 'use-wand' then
                    button:setEnabled(wand_count > 0)
                elseif action == 'use-scroll' then
                    button:setEnabled(tome_count > 0)
                elseif action == 'use-potion' then
                    button:setEnabled(potion_count > 0)
                end
            end
        end        
    end

    local enter = function(self, from)
        local handlers = {
            ['char-sheet']  = function() showCharacterSheet(player) end,
            ['inventory']   = function() showInventory(player) end,
            ['sleep']       = function() print('try sleep player') end,
            ['use-wand']    = function() showItems(getItems(player, 'wand'), 'use-wand') end,
            ['use-scroll']  = function() showItems(getItems(player, 'tome'), 'use-scroll') end,
            ['use-potion']  = function() showItems(getItems(player, 'potion'), 'use-potion') end,
            ['destroy']     = function(...) onDestroy(...) end,
            ['take']        = function() onInventoryChanged(player) end,
            ['put']         = function() onInventoryChanged(player) end,
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

    onInventoryChanged(nil)

    return setmetatable({
        -- methods
        draw            = draw,
        leave           = leave,
        enter           = enter,
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
