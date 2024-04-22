--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
]]

local M = {}

M.getColors = function(image, quad, is_sorted)
    local _, _, w, h = quad:getViewport()

    -- draw image & quad on a canvas, so we can get the image data
    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(image, quad)
    end) 
    local image_data = canvas:newImageData()

    -- store color and related pixel count in a table
    local color_info = {}
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b, a = image_data:getPixel(x, y)
            local rgba = bit.bor(
                bit.lshift(r * 255, 24),
                bit.lshift(g * 255, 16),
                bit.lshift(b * 255, 8),
                a * 255)
            local count = color_info[rgba] or 0
            color_info[rgba] = count + 1
        end
    end

    -- convert numeric color values into rgba components and store in table
    local colors = {}
    for rgba, count in pairs(color_info) do
        local r = bit.band(bit.rshift(rgba, 24), 0xFF) / 255
        local g = bit.band(bit.rshift(rgba, 16), 0xFF) / 255
        local b = bit.band(bit.rshift(rgba, 8), 0xFF) / 255
        local a = bit.band(rgba, 0xFF) / 255

        table.insert(colors, {
            color = { r, g, b, a },
            count = count,
        })
    end

    -- sort color info in colors table: from most occurences to least occurences
    if is_sorted then
        table.sort(colors, function(a, b) return a.count > b.count end)
    end

    return colors
end

return M
