--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local ChooserItem = {}

local TEXT_COLOR = { 0.0, 0.0, 0.0, 0.7 }

ChooserItem.new = function(text)
    local frame = Rect(0)

    local text_w, text_h = FONT:getWidth(text), FONT:getHeight()

    local is_highlighted, is_pressed, is_released = false, false, false
    
    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()
        is_highlighted = frame:contains(mx / UI_SCALE, my / UI_SCALE)

        is_released = false
        if is_highlighted and is_pressed and not love.mouse.isDown(1) then
            is_released = true
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)
    end
    
    local draw = function(self)
        local x, y, w, h = frame:unpack()

        if is_highlighted then
            love.graphics.setColor(0.4, 0.9, 0.8, 0.5)
            love.graphics.rectangle('fill', x, y, w, h)
        end

        love.graphics.setColor(unpack(TEXT_COLOR))
        local text_x, text_y = mfloor((w - text_w) / 2), mfloor((h - text_h) / 2)
        love.graphics.print(text, x + text_x, y + text_y)
    end

    local getFrame = function(self) return frame end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end 

    local wasPressed = function(self) return is_released end

    local getText = function(self) return text end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        getText     = getText,
        setFrame    = setFrame,
        getFrame    = getFrame,
        wasPressed  = wasPressed,
    }, ChooserItem)
end

return setmetatable(ChooserItem, {
    __call = function(_, ...) return ChooserItem.new(...) end,
})
