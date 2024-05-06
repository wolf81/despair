--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Portrait = {}

local HAIR_INDICES = {
    ['male']    = { 0, 11, 19, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 98, 99, 100, 101, 102, 103 },
    ['female']  = { 0, 27, 28, 29, 30, 31, 32, 44, 45, 46, 104, 114, 115, 122 },
}

local BEARD_INDICES = { 0, 76, 77, 78, 79, 80, 87, 88, 89, 90, 105, 106, 107, 108, 109, 110 }

Portrait.new = function(gender, race, class)
    gender = string.lower(gender or 'male')
    race = string.lower(race or 'human')
    class = string.lower(class or 'fighter')

    local texture = TextureCache:get('uf_portraits')
    local quads = QuadCache:get('uf_portraits')

    local quad_w, quad_h = select(3, quads[1]:getViewport())
    local frame = Rect(0, 0, quad_w, quad_h)

    local background_quad, border_quad = quads[6], quads[7]

    local hair_indices, hair_idx, beard_idx = HAIR_INDICES[gender], 1, 1

    local face_quad, beard_quad, armor_quad = nil, nil, nil
    local helmet_quad, eyebrow_quad, accessory_quad = nil, nil, nil

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, background_quad, x, y, 0)

        if face_quad then
            love.graphics.draw(texture, face_quad, x, y, 0)
        end

        if eyebrow_quad then
            love.graphics.draw(texture, eyebrow_quad, x, y, 0)
        end

        if armor_quad then
            love.graphics.draw(texture, armor_quad, x, y, 0)
        end

        if beard_idx > 1 then
            love.graphics.draw(texture, quads[BEARD_INDICES[beard_idx]], x, y, 0)
        end

        if hair_idx > 1 then
            love.graphics.draw(texture, quads[hair_indices[hair_idx]], x, y, 0)
        end

        if accessory_quad then
            love.graphics.draw(texture, accessory_quad, x, y, 0)
        end

        if helmet_quad then
            love.graphics.draw(texture, helmet_quad, x, y, 0)
        end

        love.graphics.draw(texture, border_quad, x, y, 0)
    end

    local update = function(self) end

    local getFrame = function(self) return frame end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getSize = function(self) return frame:getSize() end

    local prevHair = function(self) hair_idx = (hair_idx - 1) % #hair_indices end

    local nextHair = function(self) hair_idx = (hair_idx % #hair_indices) + 1 end

    local prevBeard = function(self) beard_idx = (beard_idx - 1) % #BEARD_INDICES end

    local nextBeard = function(self) beard_idx = (beard_idx % #BEARD_INDICES) + 1 end

    local setFaceIndex = function(self, quad_idx) face_quad = quads[quad_idx] end

    local setHairIndex = function(self, quad_idx) hair_quad = quads[quad_idx] end
    
    local setArmorIndex = function(self, quad_idx) armor_quad = quads[quad_idx] end

    local setHelmetIndex = function(self, quad_idx) helmet_quad = quads[quad_idx] end

    local setEyebrowIndex = function(self, quad_idx) eyebrow_quad = quads[quad_idx] end

    local setAccessoryIndex = function(self, quad_idx) accessory_quad = quads[quad_idx] end

    return setmetatable({
        -- methods
        draw                = draw,
        update              = update,
        getSize             = getSize,
        getFrame            = getFrame,
        setFrame            = setFrame,
        prevHair            = prevHair,
        nextHair            = nextHair,
        prevBeard           = prevBeard,
        nextBeard           = nextBeard,
        setFaceIndex        = setFaceIndex,
        setArmorIndex       = setArmorIndex,
        setHelmetIndex      = setHelmetIndex,
        setEyebrowIndex     = setEyebrowIndex,
        setAccessoryIndex   = setAccessoryIndex,
    }, Portrait)
end

return setmetatable(Portrait, {
    __call = function(_, ...) return Portrait.new(...) end,
})
