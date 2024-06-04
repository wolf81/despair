--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local ImageButton = {}

local DISABLED_ALPHA = 0.7

local function generateTexture(image)
    local image_w, image_h = image:getDimensions()
    local background = TextureGenerator.generatePanelTexture(image_w, image_h)

    local canvas = love.graphics.newCanvas(image_w, image_h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, 0, 0)
        love.graphics.draw(image, 0, 0)
    end)

    return canvas
end

ImageButton.new = function(image, action, ...)
    assert(image ~= nil, 'missing argument: "image"')

    local frame = Rect(0)

    local args = {...}

    local is_highlighted, is_pressed, is_enabled = false, false, true

    local background = nil

    local texture = generateTexture(image)

    local update = function(self, dt)
        if not is_enabled then return end

        if quad_idx == 0 then return end

        local mx, my = love.mouse.getPosition()
        is_highlighted = frame:contains(mx / UI_SCALE, my / UI_SCALE)

        if is_highlighted and is_pressed and not love.mouse.isDown(1) then
            is_pressed = false
            
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

        -- add white background behind texture for showing disabled state
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.rectangle('fill', x + 1, y + 1, w - 2, h - 2)

        love.graphics.setColor(1.0, 1.0, 1.0, is_enabled and 1.0 or DISABLED_ALPHA)

        if is_enabled and is_highlighted then
            love.graphics.setColor(0.5, 1.0, 0.9, 1.0)
        end

        love.graphics.draw(texture, x, y)
    end

    local getSize = function(self) return frame:getSize() end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame:unpack() end

    local setEnabled = function(self, flag) is_enabled = (flag == true) end

    local setImage = function(self, image_)
        assert(image ~= nil, 'missing argument: "image_"')
        -- image = image_ 

        texture = generateTexture(image_)
    end
    
    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        getFrame    = getFrame,
        setFrame    = setFrame,
        setImage    = setImage,
        setEnabled  = setEnabled,
    }, ImageButton)
end

return setmetatable(ImageButton, {
    __call = function(_, ...) return ImageButton.new(...) end,
})
