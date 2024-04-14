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

    local portrait = Portrait(player)
    local profile_btn = ImageButton(portrait:getImage(), 'char-sheet')
    table.insert(buttons, profile_btn)

    local use_actions = { 'use-potion', 'use-wand', 'use-scroll' }
    for _, action in ipairs(use_actions) do
        local button = ActionBarButton(action)
        table.insert(buttons, button)
    end

    local game_actions = { 'sleep', 'inventory', 'settings' }
    for _, action in ipairs(game_actions) do
        local button = ActionBarButton(action)
        table.insert(buttons, button)
    end

    local left_action_count = #generic_actions + #class_actions
    local right_action_count = #use_actions

    local half_w = (WINDOW_W - INFO_PANEL_W) / 2

    local left_spacing = half_w - left_action_count * 48 - portrait:getSize() / 2
    local right_spacing = half_w - right_action_count * 48 - portrait:getSize() / 2

    table.insert(buttons, #generic_actions + 1, FlexSpace(left_spacing, ACTION_BAR_H))
    table.insert(buttons, #buttons - 2, FlexSpace(right_spacing, ACTION_BAR_H))

    local update = function(self, dt) 
        for _, button in ipairs(buttons) do
            button:update(dt)
        end
    end

    local draw = function(self, x, y)
        local ox = 0

        for _, button in ipairs(buttons) do
            button_w, button_h = button:getSize()
            button:draw(x + ox, y + ACTION_BAR_H - button_h)
            ox = ox + button_w
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
