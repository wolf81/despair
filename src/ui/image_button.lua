--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local ImageButton = {}

ImageButton.new = function(image, action, ...)
    assert(image ~= nil, 'missing argument: "image"')

    local frame = Rect(0)

    local args = {...}

    local is_highlighted, is_pressed, is_enabled = false, false, true

    local update = function(self, dt)
        if not is_enabled then return end

        if quad_idx == 0 then return end

        local mx, my = love.mouse.getPosition()
        is_highlighted = frame:contains(mx / UI_SCALE, my / UI_SCALE)

        if is_highlighted and is_pressed and (not love.mouse.isDown(1)) then
            if action then
                local action_type = type(action)
                if action_type == 'string' then
                    Signal.emit(action, unpack(args))
                elseif action_type == 'function' then
                    action(unpack(args))
                else
                    error('invalid argument for "action", expected: "string" or "function"')
                end
            end
        end

        is_pressed = is_highlighted and love.mouse.isDown(1)
    end

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, is_enabled and 1.0 or 0.8)

        if is_highlighted then
            love.graphics.setColor(0.4, 0.9, 0.8, 1.0)
        end

        local image_w, image_h = image:getDimensions()

        love.graphics.draw(image, x - 1, y - 1)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    local getSize = function(self) return frame:getSize() end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame:unpack() end

    local setEnabled = function(self, flag) is_enabled = (flag == true) end
    
    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        getFrame    = getFrame,
        setFrame    = setFrame,
        setEnabled  = setEnabled,
    }, ImageButton)
end

return setmetatable(ImageButton, {
    __call = function(_, ...) return ImageButton.new(...) end,
})
