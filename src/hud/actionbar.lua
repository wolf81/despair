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
    ['cleric']  = { 'turn-undead', 'cast-spell',  },
    ['rogue']   = { 'stealth', 'search', 'steal',  },
    ['mage']    = { 'cast-spell',  },
}

Actionbar.new = function(player)
    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')

    local combat_actions = { 'swap-weapon', 'use-potion', 'use-wand', 'use-scroll', 'sleep' }
    local class_actions = CLASS_ACTIONS[player.class]
    local other_actions = { 'inventory', 'profile' }

    local actions = lume.concat(combat_actions, class_actions, other_actions)
    local _, _, quad_w, quad_h = quads[1]:getViewport()

    local w = #actions * quad_w

    local update = function(self, dt) 
        -- body
    end

    local draw = function(self, x, y)
        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.rectangle('fill', x, y, w, quad_h)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.rectangle('line', x, y, w, quad_h)

        for idx, action in ipairs(actions) do
            local frame_idx = ACTION_INFO[action]
            love.graphics.draw(texture, quads[frame_idx], x + (idx - 1) * quad_w, y)
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
