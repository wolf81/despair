--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local ScrollbarButton = {}

ScrollbarButton.new = function(direction)
    local frame = Rect(0)

    local image = nil
    local image_w, image_h = 0, 0

    local is_highlighted, is_pressed = false, false

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        if is_highlighted then
            love.graphics.setColor(0.4, 0.9, 0.8, 0.5)
            love.graphics.rectangle('fill', x, y, w, h)
        end

        love.graphics.setColor(1.0, 1.0, 1.0, 0.7)
        love.graphics.draw(image, x + mfloor((w - image_w) / 2) - 1, y + mfloor((h - image_h) / 2))

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.rectangle('line', x, y, w, h)
    end

    local update = function(self, dt) 
        local mx, my = love.mouse.getPosition()
        is_highlighted = frame:contains(mx / UI_SCALE, my / UI_SCALE)
        is_pressed = is_highlighted and love.mouse.isDown(1)
    end

    local setFrame = function(self, x, y, w, h)
        frame = Rect(x, y, w, h)

        image = TextureGenerator.generateScrollerTexture(w - 2, h - 2, direction)
        image_w, image_h = image:getDimensions()
    end

    local getFrame = function(self) return frame end

    local isPressed = function(self) return is_pressed end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        setFrame    = setFrame,
        getFrame    = getFrame,
        isPressed   = isPressed,
    }, ScrollbarButton)
end

return setmetatable(ScrollbarButton, {
    __call = function(_, ...) return ScrollbarButton.new(...) end,
})
