local ItemBar = {}

ItemBar.new = function(items)
    local frame = { 0, 0, 0, 0 }

    local item_background = TextureGenerator.generateContainerTexture()
    local image_w, image_h = item_background:getDimensions()

    local background = TextureGenerator.generatePanelTexture(image_w * #items + 6, image_h + 6)

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        local x, y = unpack(frame)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.draw(background, x - 3, y - 3)

        local ox = 0
        for _, item in ipairs(items) do
            love.graphics.draw(item_background, x + ox, y)

            local def = EntityFactory.getDefinition(item.id)
            local texture = TextureCache:get(def.texture)
            local quads = QuadCache:get(def.texture)
            local frame = def.anim[1]

            love.graphics.draw(texture, quads[frame], x + ox, y)

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
