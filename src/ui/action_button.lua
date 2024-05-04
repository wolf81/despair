--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local ActionButton = {}

local DISABLED_ALPHA = 0.7

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
    ['use-food']    = 22,
}

ActionButton.new = function(action, ...)
    assert(arg ~= nil, 'missing argument: "action"')

    local args = {...}

    local texture = TextureCache:get('actionbar')
    local quads = QuadCache:get('actionbar')
    local quad_idx = ACTION_INFO[action]

    local frame = Rect(0)
    
    local is_enabled, is_selected, is_highlighted, is_pressed = true, false, false, false
    
    local background = nil

    local update = function(self, dt)
        if quad_idx == 0 then return end

        if not is_enabled then return end

        local mx, my = love.mouse.getPosition()
        is_highlighted = is_selected or frame:contains(mx / UI_SCALE, my / UI_SCALE)

        if is_highlighted and is_pressed and not love.mouse.isDown(1) then
            is_pressed = false
            
            local action_type = type(action)
            if action_type == 'string' then
                Signal.emit(action, unpack(args))
            elseif action_type == 'function' then
                action(unpack(args))
            end
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)
    end

    local draw = function(self)
        if not background then return end

        local x, y, w, h = frame:unpack()

        -- add white background behind texture for showing disabled state
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.rectangle('fill', x + 1, y + 1, w - 2, h - 2)

        love.graphics.setColor(1.0, 1.0, 1.0, (is_enabled and 1.0 or DISABLED_ALPHA))
        love.graphics.draw(background, x, y)

        if is_enabled and (is_highlighted or is_selected) then
            love.graphics.setColor(0.5, 1.0, 0.9, 1.0)
        end

        love.graphics.draw(texture, quads[quad_idx], x, y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    local setFrame = function(self, x, y, w, h)
        frame = Rect(x, y, w, h)
        
        if w > 0 and h > 0 then
            background = TextureGenerator.generatePanelTexture(w, h)
        end
    end

    local getFrame = function(self) return frame:unpack() end

    local setSelected = function(self, flag) is_selected = (flag == true) end

    local isSelected = function(self) return is_selected end

    local setEnabled = function(self, flag) 
        is_enabled = (flag == true) 

        if not is_enabled then
            is_highlighted = false
            is_selected = false
            is_pressed = false
        end
    end

    local isEnabled = function(self) return is_enabled end

    local getAction = function(self) return action end
    
    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        setFrame    = setFrame,
        getFrame    = getFrame,
        isEnabled   = isEnabled,
        getAction   = getAction,
        isSelected  = isSelected,
        setEnabled  = setEnabled,
        setSelected = setSelected,
    }, ActionButton)
end

return setmetatable(ActionButton, {
    __call = function(_, ...) return ActionButton.new(...) end,
})
