local ImageButton = {}

ImageButton.new = function(image, action)
    assert(image ~= nil, 'missing argument: "image"')

    local btn_w, btn_h = image:getDimensions()
    local btn_x, btn_y = 0, 0

    local is_highlighted, is_pressed = false, false

    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()

        if quad_idx == 0 then return end

        is_highlighted = (mx > btn_x) and (my > btn_y) and (mx < btn_x + btn_w) and (my < btn_y + btn_h)

        if is_highlighted and is_pressed and (not love.mouse.isDown(1)) then
            if action then
                Signal.emit(action)
            end
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)

    end

    local draw = function(self, x, y)
        btn_x, btn_y = x, y

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        if is_highlighted then
            love.graphics.setColor(0.4, 0.9, 0.8, 1.0)
        end

        love.graphics.draw(image, btn_x, btn_y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    local getSize = function(self) return btn_w, btn_h end
    
    return setmetatable({
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, ImageButton)
end

return setmetatable(ImageButton, {
    __call = function(_, ...) return ImageButton.new(...) end,
})
