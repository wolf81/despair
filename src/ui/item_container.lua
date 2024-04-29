--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local ItemContainer = {}

ItemContainer.new = function(id)
    local image = TextureGenerator.generateContainerTexture()
    local image_w, image_h = image:getDimensions()

    local frame = Rect(0, 0, image_w, image_h)

    local item_info = {
        item    = nil,
        texture = nil,
        quad    = nil,
    }

    local update = function(self)
        -- body
    end

    local draw = function(self)
        local x, y = frame:unpack()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(image, x, y)

        if item_info.item then
            love.graphics.draw(item_info.texture, item_info.quad, x, y)
        end
    end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame:unpack() end

    local getSize = function(self) return frame:getSize() end

    local setItem = function(self, item)
        if not item then
            item_info.item = nil
            item_info.texture = nil
            item_info.quad = nil
        else
            local def = EntityFactory.getDefinition(item.id)
            local quads = QuadCache:get(def.texture)
            local frame = def.anim[1]

            item_info.item = item
            item_info.texture = TextureCache:get(def.texture)
            item_info.quad = quads[frame]
        end
    end

    local getItem = function(self) return item_info.item end

    local getId = function(self) return id end

    return setmetatable({
        -- methods
        setFrame    = setFrame,
        getFrame    = getFrame,
        setItem     = setItem,
        getItem     = getItem,
        getSize     = getSize,
        update      = update,
        getId       = getId,
        draw        = draw,
    }, ItemContainer)
end

return setmetatable(ItemContainer, {
    __call = function(_, ...) return ItemContainer.new(...) end,
})
