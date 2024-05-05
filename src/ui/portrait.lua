--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Portrait = {}

Portrait.new = function(scale)
    scale = scale or 1

    local texture = TextureCache:get('uf_portraits')
    local quads = QuadCache:get('uf_portraits')

    local quad_w, quad_h = select(3, quads[1]:getViewport())
    local frame = Rect(0, 0, quad_w * scale, quad_h * scale)

    local background_quad, border_quad = quads[6], quads[7]

    local face_quad, hair_quad, beard_quad, armor_quad, helmet_quad = nil, nil, nil, nil, nil

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, background_quad, x, y, 0, scale, scale)

        if face_quad then
            love.graphics.draw(texture, face_quad, x, y, 0, scale, scale)
        end

        if armor_quad then
            love.graphics.draw(texture, armor_quad, x, y, 0, scale, scale)
        end

        if beard_quad then
            love.graphics.draw(texture, beard_quad, x, y, 0, scale, scale)
        end

        if hair_quad then
            love.graphics.draw(texture, hair_quad, x, y, 0, scale, scale)
        end

        if helmet_quad then
            love.graphics.draw(texture, helmet_quad, x, y, 0, scale, scale)
        end

        love.graphics.draw(texture, border_quad, x, y, 0, scale, scale)
    end

    local update = function(self) end

    local getFrame = function(self) return frame end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getSize = function(self) return frame:getSize() end

    local setFaceIndex = function(self, quad_idx) face_quad = quads[quad_idx] end

    local setHairIndex = function(self, quad_idx) hair_quad = quads[quad_idx] end
    
    local setBeardIndex = function(self, quad_idx) beard_quad = quads[quad_idx] end

    local setArmorIndex = function(self, quad_idx) armor_quad = quads[quad_idx] end

    local setHelmetIndex = function(self, quad_idx) helmet_quad = quads[quad_idx] end

    return setmetatable({
        -- methods
        draw            = draw,
        update          = update,
        getSize         = getSize,
        getFrame        = getFrame,
        setFrame        = setFrame,
        setFaceIndex    = setFaceIndex,
        setHairIndex    = setHairIndex,
        setBeardIndex   = setBeardIndex,
        setArmorIndex   = setArmorIndex,
        setHelmetIndex  = setHelmetIndex,
    }, Portrait)
end

return setmetatable(Portrait, {
    __call = function(_, ...) return Portrait.new(...) end,
})
