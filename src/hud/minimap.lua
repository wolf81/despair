--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Minimap = {}

local function generateBackgroundTexture(size)
    size = size or 5

    local key = 'uf_interface'
    local texture = TextureCache:get(key)
    local quads = QuadCache:get(key)

    local draw_info = {}
    for y = 1, size do
        for x = 1, size do
            if y == 1 then
                draw_info[vector(x, y)] = (x == 1 and 270) or (x == size and 275) or 271 
            elseif y == size then
                draw_info[vector(x, y)] = (x == 1 and 280) or (x == size and 279) or 277
            elseif x == 1 then
                draw_info[vector(x, y)] = 278
            elseif x == size then
                draw_info[vector(x, y)] = 272
            end
        end
    end

    local _, _, quad_w, quad_h = quads[270]:getViewport()
    local canvas = love.graphics.newCanvas(quad_w * size, quad_h * size)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        for coord, quad_idx in pairs(draw_info) do
            local x = (coord.x - 1) * quad_w
            local y = (coord.y - 1) * quad_h
            love.graphics.draw(texture, quads[quad_idx], x, y)            
        end

        local color_info = ColorHelper.getColors(texture, quads[270], true)[1]
        love.graphics.setColor(unpack(color_info.color))
        love.graphics.rectangle('fill', quad_w, quad_h, quad_w * (size - 1), quad_h * (size - 1))        
    end)

    return canvas
end

Minimap.new = function(player)
    local background = generateBackgroundTexture(7)

    local draw = function(self, x, y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)
    end

    local getSize = function()
        return background:getDimensions()
    end

    return setmetatable({
        -- methods
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, Minimap)
end

return setmetatable(Minimap, {
    __call = function(_, ...) return Minimap.new(...) end
})
