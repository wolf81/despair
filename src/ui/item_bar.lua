local ItemBar = {}

ItemBar.new = function(items)
    local frame = { 0, 0, 0, 0 }

    local item_background = TextureGenerator.generateContainerTexture()
    local image_w, image_h = item_background:getDimensions()

    local background = TextureGenerator.generatePanelTexture(image_w * #items, image_h)

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        local x, y = unpack(frame)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.draw(background, x, y)

        local ox = 0
        for _, item in ipairs(items) do
            love.graphics.draw(item_background, x + ox, y)
            ox = ox + image_w
        end
    end

    local setFrame = function(self, x, y, w, h)
        frame = { x, y, w, h }
    end

    local getSize = function(self) 
        return image_w * #items, image_h
    end

    return setmetatable({
        setFrame    = setFrame,
        getSize     = getSize,
        update      = update,
        draw        = draw,
    }, ItemBar)
end

return setmetatable(ItemBar, {
    __call = function(_, ...) return ItemBar.new(...) end,
})
