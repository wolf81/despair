--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.generate = function()
    local chars = "1234567890!#$%&*()-+=[]:;\"'<>,.?/abcdefghijklmnopqrstuvwxyz       ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    local key = 'uf_interface'
    local texture = TextureCache:get(key)
    local quads = QuadCache:get(key)

    local _, _, quad_w, quad_h = quads[1]:getViewport()
    local out_w, out_h = (quad_w + 2) * string.len(chars) + 2, quad_h    

    local canvas = love.graphics.newCanvas(out_w, out_h)
    canvas:renderTo(function() 
        love.graphics.setLineWidth(2.0)

        local x = 1

        for i = 1, string.len(chars) do
            love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
            love.graphics.line(x, 0, x, quad_h)
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            x = x + 1
            love.graphics.draw(texture, quads[i], x, 0)
            x = x + quad_w + 1
        end

        love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
        love.graphics.line(x, 0, x, quad_h)
    end)

    local image_data = canvas:newImageData()
    image_data:encode('png', 'image_font.png')
end

return M
