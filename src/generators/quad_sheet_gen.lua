local M = {}

M.generate = function()
    for key, image in TextureCache:each() do
        local w, h = image:getDimensions()

        local font = love.graphics.newFont(10)
        love.graphics.setFont(font)

        local canvas = love.graphics.newCanvas(w, h)
        canvas:renderTo(function() 
            love.graphics.draw(image, 0, 0)

            local quads = QuadCache:get(key)                    

            for idx, quad in ipairs(quads) do
                local x, y, w, h = quad:getViewport()

                if idx % 8 == 0 then
                    love.graphics.setColor(0.0, 1.0, 1.0, 0.5)
                else
                    love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
                end

                love.graphics.rectangle('fill', x, y, w, h)

                if (w >= 24 and h >= 12) or idx % 8 == 0 then
                    love.graphics.setColor(1.0, 1.0, 0.0, 1.0)
                    love.graphics.print(idx, x + 1.0, y + 1.0)
                end
            end
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end)

        local image_data = canvas:newImageData()
        image_data:encode('png', key .. '.png')
    end

    print('quad sheets saved at path: ' .. love.filesystem.getSaveDirectory())
end

return M
