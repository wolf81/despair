--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local ActionBarButton = {}

local ACTION_INFO = {
    ['inventory']   = 2,
    ['settings']    = 4,
    ['attack']      = 6,
    ['stealth']     = 7,
    ['turn-undead'] = 8,
    ['use-wand']    = 9,
    ['push']        = 10,
    ['shoot']       = 11,
    ['use-potion']  = 14,
    ['search']      = 15,
    ['sleep']       = 16,
    ['use-scroll']  = 17,
    ['char-sheet']  = 18,
    ['steal']       = 19,
    ['cast-spell']  = 20,
    ['swap-weapon'] = 21, 
}

ActionBarButton.new = function(arg)
    assert(arg ~= nil, 'missing argument: "string" or "number"')

    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')
    local quad_idx = 0

    local bar_x, bar_y = 0, 0
    local _, _, bar_w, bar_h = quads[1]:getViewport()

    local is_highlighted = false
    local is_pressed = false
    local action = function() end

    local arg_type = type(arg)
    if arg_type == 'string' then
        assert(ACTION_INFO[arg] ~= nil, 'invalid action name: "' .. arg .. '"')
        quad_idx = ACTION_INFO[arg]
    elseif arg_type == 'number' then
        bar_w = arg
    else
        error('invalid argument type "' .. arg_type .. '", expected: "string" or "number"')
    end
    
    local background = TextureGenerator.generatePanelTexture(bar_w, bar_h)

    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()

        if quad_idx == 0 then return end

        is_highlighted = (mx > bar_x) and (my > bar_y) and (mx < bar_x + bar_w) and (my < bar_y + bar_h)

        if is_highlighted and is_pressed and (not love.mouse.isDown(1)) then
            if arg_type == 'string' then Signal.emit(arg) end
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)
    end

    local draw = function(self, x, y)
        bar_x, bar_y = x, y

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, bar_x, bar_y)

        if quad_idx > 0 then
            if is_highlighted then
                love.graphics.setColor(0.4, 0.9, 0.8, 1.0)
            end

            love.graphics.draw(texture, quads[quad_idx], x, y)
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    local getSize = function(self) return bar_w, bar_h end
    
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
