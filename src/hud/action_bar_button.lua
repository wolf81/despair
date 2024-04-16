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

ActionBarButton.new = function(action)
    assert(arg ~= nil, 'missing argument: "action"')

    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')
    local quad_idx = ACTION_INFO[action]

    local frame = { 0, 0, 0, 0, }
    
    local is_highlighted, is_pressed = false, false
    
    local background = nil

    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()

        local x, y, w, h = unpack(frame)

        if quad_idx == 0 then return end

        is_highlighted = (mx > x) and (my > y) and (mx < x + w) and (my < y + h)

        if is_highlighted and is_pressed and (not love.mouse.isDown(1)) then
            Signal.emit(action)
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)
    end

    local draw = function(self)
        if not background then return end

        local x, y = unpack(frame)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        if is_highlighted then
            love.graphics.setColor(0.4, 0.9, 0.8, 1.0)
        end

        love.graphics.draw(texture, quads[quad_idx], x, y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    local getSize = function(self) return frame[3], frame[4] end

    local setFrame = function(self, x, y, w, h)
        frame = { x, y, w, h, }
        print('setFrame', x, y, w, h)
        
        if w > 0 and h > 0 then
            background = TextureGenerator.generatePanelTexture(w, h)
        end
    end
    
    return setmetatable({
        -- methods
        setFrame = setFrame,
        getSize = getSize,
        update  = update,
        draw    = draw,    
    }, ActionBarButton)
end

return setmetatable(ActionBarButton, {
    __call = function(_, ...) return ActionBarButton.new(...) end,
})
