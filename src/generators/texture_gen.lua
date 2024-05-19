--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local M = {}

local function getParchmentColor()
    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')    
    local color_info = ColorHelper.getColors(texture, quads[266], true)[1]
    return color_info.color
end

M.generateTextButtonTexture = function(w, h, text) 
    local image = TextureGenerator.generatePanelTexture(w, h)
    local w, h = image:getDimensions()

    local text_w, text_h = FONT:getWidth(text), FONT:getHeight()
    local text_x, text_y = mfloor((w - text_w) / 2), mfloor((h - text_h) / 2)

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
        love.graphics.draw(image, 0, 0)
        love.graphics.print(text, text_x, text_y)
    end)

    return canvas
end

M.generateImageButtonTexture = function(w, h, quad_idx)
    local canvas = TextureGenerator.generateBorderTexture(24, 24, { 0.5, 0.1, 0.1, 1.0 })

    local texture = TextureCache:get('uf_interface')
    local quad = QuadCache:get('uf_interface')[quad_idx]
    local quad_w, quad_h = select(3, quad:getViewport())

    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        local w, h = canvas:getDimensions()
        love.graphics.draw(texture, quad, mfloor((w - quad_w) / 2), mfloor((h - quad_h) / 2))
    end)
    
    return canvas
end

M.generateScrollerTexture = function(w, h, direction)
    local margin = 4

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        local x1, y1 = margin, margin
        local x2, y2 = w - x1, h - y1
        local x_mid = mfloor(w / 2)

        love.graphics.setColor(0.0, 0.0, 0.0, 1.0)

        if direction == 'up' then
            love.graphics.polygon('fill', x1, y2, x2, y2, x_mid, y1)
        else
            love.graphics.polygon('fill', x1, y1, x2, y1, x_mid, y2)
        end
    end)

    return canvas
end

M.generateBorderTexture = function(w, h, bg_color)
    assert(w ~= nil, 'missing argument: "w')

    h = h or w

    local texture = TextureCache:get('border')
    local quads = QuadCache:get('border')
    local quad_w, quad_h = select(3, quads[1]:getViewport())

    bg_color = bg_color or getParchmentColor()

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        love.graphics.setColor(unpack(bg_color))
        love.graphics.rectangle('fill', 0, 0, w, h)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        -- corners
        love.graphics.draw(texture, quads[1], 0, 0)
        love.graphics.draw(texture, quads[7], w - quad_w, 0)
        love.graphics.draw(texture, quads[4], 0, h - quad_h)
        love.graphics.draw(texture, quads[8], w - quad_w, h - quad_h)

        -- top & bottom rows
        for x = quad_w, w - quad_w * 2, quad_w do
            love.graphics.draw(texture, quads[2], x, 0)
            love.graphics.draw(texture, quads[5], x, h - quad_h)
        end

        if w > 32 then
            love.graphics.draw(texture, quads[2], w - quad_w * 2, 0)
            love.graphics.draw(texture, quads[5], w - quad_w * 2, h - quad_h)
        end

        if h > 32 then
            -- middle
            for y = quad_h, h - quad_h * 2, quad_h do
                love.graphics.draw(texture, quads[3], 0, y)
                love.graphics.draw(texture, quads[6], w - quad_w, y)
            end

            love.graphics.draw(texture, quads[3], 0, h - quad_h * 2)
            love.graphics.draw(texture, quads[6], w - quad_w, h - quad_h * 2)
        end
    end)

    return canvas
end

M.generateParchmentTexture = function(w, h)
    assert(w ~= nil, 'missing argument: "w"')

    h = h or w

    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local quad_w, quad_h = select(3, quads[266]:getViewport())

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        -- corners
        love.graphics.draw(texture, quads[266], 0, 0)
        love.graphics.draw(texture, quads[271], w - quad_w, 0)
        love.graphics.draw(texture, quads[276], 0, h - quad_h)
        love.graphics.draw(texture, quads[275], w - quad_w, h - quad_h)

        -- top & bottom rows
        for x = quad_w, w - quad_w * 2, quad_w do
            love.graphics.draw(texture, quads[267], x, 0)
            love.graphics.draw(texture, quads[273], x, h - quad_h)
        end

        love.graphics.draw(texture, quads[267], w - quad_w * 2, 0)
        love.graphics.draw(texture, quads[273], w - quad_w * 2, h - quad_h)

        -- middle
        for y = quad_h, h - quad_h * 2, quad_h do
            love.graphics.draw(texture, quads[274], 0, y)
            love.graphics.draw(texture, quads[268], w - quad_w, y)
        end

        love.graphics.draw(texture, quads[274], 0, h - quad_h * 2)
        love.graphics.draw(texture, quads[268], w - quad_w, h - quad_h * 2)

        local color_info = ColorHelper.getColors(texture, quads[266], true)[1]
        love.graphics.setColor(unpack(color_info.color))
        love.graphics.rectangle('fill', quad_w, quad_h, w - quad_w * 2, h - quad_h * 2)        
    end)

    return canvas
end

M.generateContainerTexture = function(w, h)
    w = w or 48
    h = h or w

    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local quad_w, quad_h = select(3, quads[342]:getViewport())

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        -- corners
        love.graphics.draw(texture, quads[342], 0, 0)
        love.graphics.draw(texture, quads[346], w - quad_w, 0)
        love.graphics.draw(texture, quads[347], 0, h - quad_h)
        love.graphics.draw(texture, quads[351], w - quad_w, h - quad_h)

        -- top & bottom rows
        for x = quad_w, w - quad_w * 2, quad_w do
            love.graphics.draw(texture, quads[343], x, 0)
            love.graphics.draw(texture, quads[348], x, h - quad_h)
        end

        love.graphics.draw(texture, quads[343], w - quad_w * 2, 0)
        love.graphics.draw(texture, quads[348], w - quad_w * 2, h - quad_h)

        -- middle
        for y = quad_h, h - quad_h * 2, quad_h do
            love.graphics.draw(texture, quads[344], 0, y)
            love.graphics.draw(texture, quads[349], w - quad_w, y)
        end

        love.graphics.draw(texture, quads[344], 0, h - quad_h * 2)
        love.graphics.draw(texture, quads[349], w - quad_w, h - quad_h * 2)

        local color_info = ColorHelper.getColors(texture, quads[342], true)[1]
        love.graphics.setColor(color_info.color)
        love.graphics.rectangle('fill', quad_w, quad_h, w - quad_w * 2, h - quad_h * 2)
    end)

    return canvas
end

M.generatePanelTexture = function(w, h)
    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local quad_w, quad_h = select(3, quads[332]:getViewport())

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        -- corners
        love.graphics.draw(texture, quads[332], 0, 0)
        love.graphics.draw(texture, quads[336], w - 16, 0)
        love.graphics.draw(texture, quads[337], 0, h - 16)
        love.graphics.draw(texture, quads[341], w - 16, h - 16)

        -- top & bottom rows
        for x = quad_w, w - quad_w * 2, quad_w do
            love.graphics.draw(texture, quads[333], x, 0)
            love.graphics.draw(texture, quads[338], x, h - quad_h)
        end
        
        -- middle
        if w > 32 then
            love.graphics.draw(texture, quads[333], w - quad_w * 2, 0)
            love.graphics.draw(texture, quads[338], w - quad_w * 2, h - quad_h)
        end

        if h > 32 then
            for y = quad_h, h - quad_h * 2, quad_h do
                love.graphics.draw(texture, quads[334], 0, y)
                love.graphics.draw(texture, quads[339], w - quad_w, y)
            end

            love.graphics.draw(texture, quads[334], 0, h - quad_h * 2)
            love.graphics.draw(texture, quads[339], w - quad_w, h - quad_h * 2)
        end

        local color_info = ColorHelper.getColors(texture, quads[332], true)[1]
        love.graphics.setColor(unpack(color_info.color))
        love.graphics.rectangle('fill', 16, 16, w - 32, h - 32)
    end)

    return canvas
end

M.generateColorTexture = function(w, h, color)
    assert(w ~= nil, 'missing argument: "w')

    -- if no height is defined, make height equal to width
    h = h or w

    -- if no color is defined, generate a white color texture
    color = color or { 1.0, 1.0, 1.0, 1.0 }

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle('fill', 0, 0, w, h)
    end)

    return canvas
end

return M
