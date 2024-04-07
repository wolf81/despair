--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

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
                draw_info[vector(x, y)] = (x == 1 and 266) or (x == size and 271) or 267 
            elseif y == size then
                draw_info[vector(x, y)] = (x == 1 and 276) or (x == size and 275) or 273
            elseif x == 1 then
                draw_info[vector(x, y)] = 274
            elseif x == size then
                draw_info[vector(x, y)] = 268
            end
        end
    end

    local _, _, quad_w, quad_h = quads[266]:getViewport()
    local canvas = love.graphics.newCanvas(quad_w * size, quad_h * size)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        for coord, quad_idx in pairs(draw_info) do
            local x = (coord.x - 1) * quad_w
            local y = (coord.y - 1) * quad_h
            love.graphics.draw(texture, quads[quad_idx], x, y)            
        end

        local color_info = ColorHelper.getColors(texture, quads[266], true)[1]
        love.graphics.setColor(unpack(color_info.color))
        love.graphics.rectangle('fill', quad_w, quad_h, quad_w * (size - 2), quad_h * (size - 2))        
    end)

    return canvas
end

Minimap.new = function(player)
    local background = generateBackgroundTexture(7)

    local cartographer = player:getComponent(Cartographer)

    local draw = function(self, x, y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        local w, h = self:getSize()

        local chart = cartographer:getChartImage()
        local chart_w, chart_h = cartographer:getSize()
        local chart_x, chart_y = (w - chart_w) / 2, (h - chart_h) / 2

        love.graphics.draw(chart, x + chart_x, y + chart_y)
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
