--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local ActionBarButton = {}

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

ActionBarButton.new = function(arg)
    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')

    local _, _, w, h = quads[1]:getViewport()
    local quad_idx = 0

    local arg_type = type(arg)
    if arg_type == 'string' then
        quad_idx = ACTION_INFO[arg]    
    elseif arg_type == 'number' then
        w = arg
    else
        error('invalid argument type "' .. arg_type .. '", expected: "string" or "number"')
    end

    local background = TextureGenerator.generatePanelTexture(w, h)

    local update = function(self, dt)
        -- body
    end

    local draw = function(self, x, y)
        love.graphics.draw(background, x, y)

        if quad_idx > 0 then
            love.graphics.draw(texture, quads[quad_idx], x, y)
        end
    end

    local getSize = function(self) return w, h end
    
    return setmetatable({
        -- methods
        getSize = getSize,
        update  = update,
        draw    = draw,    
    }, ActionBarButton)
end

return setmetatable(ActionBarButton, {
    __call = function(_, ...) return ActionBarButton.new(...) end,
})
