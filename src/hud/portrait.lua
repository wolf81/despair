local lrandom = love.math.random

local Portrait = {}

Portrait.new = function(player)
    local key = 'uf_portraits'
    local texture = TextureCache:get(key)
    local quads = QuadCache:get(key)

    -- TODO: adjust clothes, accessories for player race and/or class

    local hair_idx = lrandom(27, 46)
    local face_idx = lrandom(51, 65)
    local hat_idx = lrandom(66, 72)
    local clothes_idx = lrandom(14, 18)
    local beard_idx = lrandom(76, 80)

    local _, _, quad_w, quad_h = quads[1]:getViewport()

    local canvas = love.graphics.newCanvas(quad_w, quad_h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, quads[6])
        love.graphics.draw(texture, quads[face_idx])
        love.graphics.draw(texture, quads[clothes_idx])
        love.graphics.draw(texture, quads[hair_idx])
        love.graphics.draw(texture, quads[beard_idx])
        love.graphics.draw(texture, quads[hat_idx])
        love.graphics.draw(texture, quads[7])
    end)

    local image = love.graphics.newImage(canvas:newImageData())

    local draw = function(self, x, y)
        love.graphics.draw(image, x, y)
    end

    local getSize = function(self)
        return quad_w, quad_h
    end

    return setmetatable({
        -- methods
        draw    = draw,
        getSize = getSize,
    }, Portrait)
end

return setmetatable(Portrait, {
    __call = function(_, ...) return Portrait.new(...) end,
})
