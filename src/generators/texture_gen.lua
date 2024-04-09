local M = {}

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
        for x = 16, w - 32, 8 do
            love.graphics.draw(texture, quads[325 + offset], x, 0)
            love.graphics.draw(texture, quads[330 + offset], x, h - 16)
        end

        -- middle
        for y = 16, h - 32, 16 do
            love.graphics.draw(texture, quads[326 + offset], x, y)
            love.graphics.draw(texture, quads[331 + offset], w - 16, y)
        end

        love.graphics.setColor(unpack(color_info.color))
        love.graphics.rectangle('fill', 16, 16, w - 32, h - 32)
    end)

    return canvas
end

return M
