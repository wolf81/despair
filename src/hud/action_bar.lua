--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local ActionBar = {}

local CLASS_ACTIONS = {
    ['fighter'] = {  },
    ['cleric']  = { 'turn-undead', 'cast-spell', },
    ['rogue']   = { 'stealth', 'search',  },
    ['mage']    = { 'cast-spell', },
}

local newActionBar = function(arg)
    assert(arg ~= nil, 'missing argument: "number" or "table"')

    local arg_type = type(arg)
    local buttons = {}
    local w, h = 0, 0

    if arg_type == 'table' then
        actions = arg        
        assert(#actions > 0, 'actions list must contain at least 1 element')

        for _, action in ipairs(actions) do
            table.insert(buttons, ActionBarButton(action))
        end

        local button_w, button_h = buttons[1]:getSize()
        w, h = #buttons * button_w, button_h
    elseif arg_type == 'number' then
        table.insert(buttons, ActionBarButton(arg))

        w, h = buttons[1]:getSize()
    else
        error('invalid type for "arg", expected: "table" or "number"')
    end

    draw = function(x, y)
        local ox = 0
        for _, button in ipairs(buttons) do
            button:draw(x + ox, y)
            ox = ox + button:getSize()
        end
    end

    local getSize = function() return w, h end

    return TableHelper.readOnly({
        getSize = getSize,
        draw    = draw,
    })
end

ActionBar.new = function(player)
    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')

    local actionsbars = {}

    local generic_actions = { 'swap-weapon' }
    table.insert(actionsbars, newActionBar(generic_actions))

    local class_actions = CLASS_ACTIONS[player.class]
    if #class_actions > 0 then
        table.insert(actionsbars, newActionBar(class_actions))
    end

    local use_actions = { 'use-potion', 'use-wand', 'use-scroll' }
    table.insert(actionsbars, newActionBar(use_actions))

    local game_actions = { 'inventory', 'profile', 'sleep' }
    table.insert(actionsbars, newActionBar(game_actions))

    local remaining_w = WINDOW_W
    for _, actionbar in ipairs(actionsbars) do
        local actionbar_w, actionbar_h = actionbar.getSize()
        remaining_w = remaining_w - actionbar_w
    end
    table.insert(actionsbars, 2, newActionBar(remaining_w / 2))
    table.insert(actionsbars, #actionsbars, newActionBar(remaining_w / 2))

    local update = function(self, dt) 
        -- body
    end

    local draw = function(self, x, y)
        local ox = 0

        for idx, actionbar in ipairs(actionsbars) do
            actionbar.draw(x + ox, y)
            ox = ox + actionbar.getSize()
        end
    end

    local getSize = function(self) return w, quad_h end

    return setmetatable({
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, ActionBar)
end

return setmetatable(ActionBar, {
    __call = function(_, ...) return ActionBar.new(...) end,
})
