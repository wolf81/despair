--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local ChooserItem = {}

local TEXT_COLOR = { 0.0, 0.0, 0.0, 0.7 }

ChooserItem.new = function(text)
    local frame = Rect(0)

    local text_w, text_h = FONTS['default']:getWidth(text), FONTS['default']:getHeight()

    local text_offset = { x = 0, y = 0 }

    local is_highlighted, is_pressed, is_released = false, false, false
    local is_selected = false
    
    local update = function(self, dt)
        is_released = false
        if is_highlighted and is_pressed and not love.mouse.isDown(1) then
            is_released = true
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)
    end
    
    local draw = function(self)
        local x, y, w, h = frame:unpack()

        if is_highlighted or is_selected then
            love.graphics.setColor(0.4, 0.9, 0.8, is_selected and 0.8 or 0.5)
            love.graphics.rectangle('fill', x, y, w, h)
        end

        love.graphics.setColor(unpack(TEXT_COLOR))
        local text_x, text_y = mfloor((w - text_w) / 2), mfloor((h - text_h) / 2)
        love.graphics.print(text, x + text_x + text_offset.x, y + text_y + text_offset.y)
    end

    local getFrame = function(self) return frame:unpack() end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end 

    local wasPressed = function(self) return is_released end

    local isHighlighted = function(self) return is_highlighted end

    local setHighlighted = function(self, flag) is_highlighted = (flag == true) end

    local setSelected = function(self, flag) is_selected = (flag == true) end

    local isSelected = function(self) return is_selected end

    local getText = function(self) return text end

    local setTextOffset = function(self, ox, oy)  
        text_offset.x = ox or 0
        text_offset.y = oy or 0
    end

    return setmetatable({
        -- methods
        draw            = draw,
        update          = update,
        getSize         = getSize,
        getText         = getText,
        setFrame        = setFrame,
        getFrame        = getFrame,
        wasPressed      = wasPressed,
        isSelected      = isSelected,
        setSelected     = setSelected,
        setTextOffset   = setTextOffset,
        isHighlighted   = isHighlighted,
        setHighlighted  = setHighlighted,
    }, ChooserItem)
end

return setmetatable(ChooserItem, {
    __call = function(_, ...) return ChooserItem.new(...) end,
})
