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

ActionBar.new = function(player)
    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')

    local buttons = {}

    local generic_actions = { 'swap-weapon' }
    for _, action in ipairs(generic_actions) do
        local button = ActionBarButton(action)
        table.insert(buttons, button)
    end

    local class_actions = CLASS_ACTIONS[player.class]
    for _, action in ipairs(class_actions) do
        local button = ActionBarButton(action)
        table.insert(buttons, button)
    end

    local seperator = ActionBarButton(32)
    table.insert(buttons, seperator)

    local use_actions = { 'use-potion', 'use-wand', 'use-scroll' }
    for _, action in ipairs(use_actions) do
        local button = ActionBarButton(action)
        table.insert(buttons, button)
    end

    local sleep = ActionBarButton('sleep')
    table.insert(buttons, sleep)

    local game_actions = { 'char-sheet', 'inventory', 'settings' }
    for _, action in ipairs(game_actions) do
        local button = ActionBarButton(action)
        table.insert(buttons, button)
    end

    local left_action_count = #generic_actions + #class_actions
    local right_action_count = #use_actions + 1

    local half_w = (WINDOW_W - INFO_PANEL_W) / 2

    local left_spacing = half_w - left_action_count * 48 - seperator:getSize() / 2
    local right_spacing = half_w - right_action_count * 48 - seperator:getSize() / 2

    table.insert(buttons, #generic_actions + 1, ActionBarButton(left_spacing))
    table.insert(buttons, #buttons - 3, ActionBarButton(right_spacing))

    local update = function(self, dt) 
        for _, button in ipairs(buttons) do
            button:update(dt)
        end
    end

    local draw = function(self, x, y)
        local ox = 0

        for idx, button in ipairs(buttons) do
            button:draw(x + ox, y)
            ox = ox + button:getSize()
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
