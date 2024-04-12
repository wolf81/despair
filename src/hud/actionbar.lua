--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Actionbar = {}

local ACTION_INFO = {
    ['inventory']       = 2,
    ['settings']        = 4,
    ['attack']          = 6,
    ['stealth']         = 7,
    ['turn-undead']     = 8,
    ['use-wand']        = 9,
    ['push']            = 10,
    ['shoot']           = 11,
    ['use-potion']      = 14,
    ['search']          = 15,
    ['sleep']           = 16,
    ['use-scroll']      = 17,
    ['profile']         = 18,
    ['steal']           = 19,
    ['cast-spell']      = 20,
    ['swap-weapon']     = 21, 
}

local CLASS_ACTIONS = {
    ['fighter'] = {  },
    ['cleric']  = { 'turn-undead', 'cast-spell', },
    ['rogue']   = { 'stealth', 'search',  },
    ['mage']    = { 'cast-spell', },
}

local newActionBar = function(texture, quads, arg)
    assert(texture ~= nil, 'missing argument: "texture"')
    assert(quads ~= nil, 'missing argument: "quads"')
    assert(arg ~= nil, 'missing argument: "number" or "table"')

    local bar_w, actions = 0, {}
    local _, _, quad_w, quad_h = quads[1]:getViewport()

    local arg_type = type(arg)
    if arg_type == 'table' then
        actions = arg        
        assert(#actions > 0, 'actions list must contain at least 1 element')

        bar_w = quad_w * #actions
    elseif arg_type == 'number' then
        bar_w = arg
    else
        error('invalid type for "arg", expected: "table" or "number"')
    end

    local background = TextureGenerator.generatePanelTexture(bar_w, quad_h)

    draw = function(x, y)
        love.graphics.draw(background, x, y)

        for idx, action in ipairs(actions) do            
            local quad_idx = ACTION_INFO[action]
            local ox = (idx - 1) * quad_w
            love.graphics.draw(texture, quads[quad_idx], x + ox, y)

            ::continue::
        end
    end

    local getSize = function() return bar_w, quad_h end

    return TableHelper.readOnly({
        getSize = getSize,
        draw    = draw,
    })
end

Actionbar.new = function(player)
    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')

    local actionsbars = {}

    local generic_actions = { 'swap-weapon' }
    table.insert(actionsbars, newActionBar(texture, quads, generic_actions))

    local class_actions = CLASS_ACTIONS[player.class]
    if #class_actions > 0 then
        table.insert(actionsbars, newActionBar(texture, quads, class_actions))
    end

    local use_actions = { 'use-potion', 'use-wand', 'use-scroll' }
    table.insert(actionsbars, newActionBar(texture, quads, use_actions))

    local game_actions = { 'inventory', 'profile', 'sleep' }
    table.insert(actionsbars, newActionBar(texture, quads, game_actions))

    local remaining_w = WINDOW_W
    for _, actionbar in ipairs(actionsbars) do
        local actionbar_w, actionbar_h = actionbar.getSize()
        remaining_w = remaining_w - actionbar_w
    end
    table.insert(actionsbars, 2, newActionBar(texture, quads, remaining_w / 2))
    table.insert(actionsbars, #actionsbars, newActionBar(texture, quads, remaining_w / 2))

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
    }, Actionbar)
end

return setmetatable(Actionbar, {
    __call = function(_, ...) return Actionbar.new(...) end,
})
