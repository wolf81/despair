local ImageButton = {}

ImageButton.new = function(image, action)
    assert(image ~= nil, 'missing argument: "image"')

    local frame = { 0, 0, 0, 0 }

    local is_highlighted, is_pressed = false, false

    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()

        if quad_idx == 0 then return end

        local x, y, w, h = unpack(frame)

        is_highlighted = (mx > x) and (my > y) and (mx < x + w) and (my < y + h)

        if is_highlighted and is_pressed and (not love.mouse.isDown(1)) then
            if action then
                Signal.emit(action)
            end
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)
    end

    local draw = function(self)
        local x, y, w, h = unpack(frame)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        if is_highlighted then
            love.graphics.setColor(0.4, 0.9, 0.8, 1.0)
        end

        local image_w, image_h = image:getDimensions()

        love.graphics.draw(image, x - 1, y - 1)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    local getSize = function(self) return frame[3], frame[4] end

    local setFrame = function(self, x, y, w, h)
        frame = { x, y, w, h }
    end
    
    return setmetatable({
        setFrame = setFrame,
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, ImageButton)
end

return setmetatable(ImageButton, {
    __call = function(_, ...) return ImageButton.new(...) end,
})
