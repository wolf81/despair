--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local M = {}

M.generateParchmentTexture = function(w, h)
    assert(w ~= nil, 'missing argument: "w')

    h = h or w

    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local quad_w, quad_h = select(3, quads[266]:getViewport())

    local cols = mfloor(w / quad_w)
    local rows = mfloor(h / quad_h) 

    local draw_info = {}
    for y = 1, rows do
        for x = 1, cols do
            if y == 1 then
                draw_info[vector(x, y)] = (x == 1 and 266) or (x == cols and 271) or 267 
            elseif y == rows then
                draw_info[vector(x, y)] = (x == 1 and 276) or (x == cols and 275) or 273
            elseif x == 1 then
                draw_info[vector(x, y)] = 274
            elseif x == cols then
                draw_info[vector(x, y)] = 268
            end
        end
    end

    local quad_w, quad_h = select(3, quads[266]:getViewport())
    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.draw(texture, quads[266], 0, 0)
        love.graphics.draw(texture, quads[271], w - quad_w, 0)
        love.graphics.draw(texture, quads[276], 0, h - quad_h)
        love.graphics.draw(texture, quads[275], w - quad_w, h - quad_h)

        -- top & bottom rows
        for x = 16, w - 24, 8 do
            love.graphics.draw(texture, quads[267], x, 0)
            love.graphics.draw(texture, quads[273], x, h - quad_h)
        end

        -- middle
        for y = quad_h, h - quad_h, quad_h do
            love.graphics.draw(texture, quads[274], 0, y)
            love.graphics.draw(texture, quads[268], w - quad_w, y)
        end

        local color_info = ColorHelper.getColors(texture, quads[266], true)[1]
        love.graphics.setColor(unpack(color_info.color))
        love.graphics.rectangle('fill', quad_w, quad_h, w - quad_w * 2, h - quad_h * 2)        
    end)

    return canvas
end

M.generateContainerTexture = function() 
    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local color_info = ColorHelper.getColors(texture, quads[334], true)[1]

    local canvas = love.graphics.newCanvas(48, 48)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.draw(texture, quads[334], 0, 0)
        love.graphics.draw(texture, quads[335], 16, 0)
        love.graphics.draw(texture, quads[338], 32, 0)

        love.graphics.draw(texture, quads[336], 0, 16)
        love.graphics.draw(texture, quads[341], 32, 16)

        love.graphics.draw(texture, quads[339], 0, 32)
        love.graphics.draw(texture, quads[340], 16, 32)
        love.graphics.draw(texture, quads[343], 32, 32)

        love.graphics.setColor(color_info.color)
        love.graphics.rectangle('fill', 16, 16, 16, 16)
    end)

    return canvas
end

M.generatePanelTexture = function(w, h)
    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')

    local offset = 34 * 0 -- offset of 0, 1, 2 to change themes: gray, blue, brown

    local color_info = ColorHelper.getColors(texture, quads[326 + offset], true)[1]

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.draw(texture, quads[324 + offset], 0, 0)
        love.graphics.draw(texture, quads[328 + offset], w - 16, 0)
        love.graphics.draw(texture, quads[329 + offset], 0, h - 16)
        love.graphics.draw(texture, quads[333 + offset], w - 16, h - 16)

        -- top & bottom rows
        for x = 16, w - 24, 8 do
            love.graphics.draw(texture, quads[325 + offset], x, 0)
            love.graphics.draw(texture, quads[330 + offset], x, h - 16)
        end

        -- middle
        for y = 16, h - 24, 8 do
            love.graphics.draw(texture, quads[326 + offset], 0, y)
            love.graphics.draw(texture, quads[331 + offset], w - 16, y)
        end

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
