--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Portrait = {}

local FACE_INDICES = {
    ['human-male']      = 61,
    ['human-female']    = 58,
    ['elf-male']        = 56,
    ['elf-female']      = 55,
    ['dwarf-male']      = 60,
    ['dwarf-female']    = 57,
    ['halfling-male']   = 62,
    ['halfling-female'] = 59,
}

local HAIR_INDICES = {
    ['male']    = { 0, 11, 19, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 98, 99, 100, 101, 102, 103 },
    ['female']  = { 0, 27, 28, 29, 30, 31, 32, 44, 45, 46, 104, 114, 115, 122 },
}

local BEARD_INDICES = { 0, 76, 77, 78, 79, 80, 87, 88, 89, 90, 105, 106, 107, 108, 109, 110 }

local ACCESSORY_INDICES = { 8, 9, 10, 11, 12, 13, 20, 21, 22, 23, 48, 49, 50, 73, 74, 75, 111, 112, 113, 114, 115, 121, 122, 123, 124 }

local HELM_INDICES = {
    ['fighter'] = { 0, 66, },
    ['cleric']  = { 0, 70, },
    ['rogue']   = { 0, 67, 68, 69, },
    ['mage']    = { 0, 71, 72, }
}

local ARMOR_INDICES = {
    ['fighter'] = { 0, 1, 2, 3, 4, 113, 119, 120, },
    ['cleric']  = { 0, 14, 15, 16, },
    ['rogue']   = { 0, 125, 126, 127, },
    ['mage']    = { 0, 17, 18, 116, 117, 118 }
}

Portrait.new = function(gender, race, class)
    gender = string.lower(gender or 'male')
    race = string.lower(race or 'human')
    class = string.lower(class or 'fighter')

    local texture = TextureCache:get('uf_portraits')
    local quads = QuadCache:get('uf_portraits')

    local quad_w, quad_h = select(3, quads[1]:getViewport())
    local frame = Rect(0, 0, quad_w, quad_h)

    local background_quad, border_quad = quads[6], quads[7]

    local hair_indices = HAIR_INDICES[gender]
    local armor_indices = ARMOR_INDICES[string.lower(class)]
    local face_idx, hair_idx, beard_idx, armor_idx = FACE_INDICES[race..'-'..gender], 1, 1, 1

    local helmet_quad, eyebrow_quad, accessory_quad = nil, nil, nil

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, background_quad, x, y, 0)

        love.graphics.draw(texture, quads[face_idx], x, y, 0)

        if eyebrow_quad then
            love.graphics.draw(texture, eyebrow_quad, x, y, 0)
        end

        if armor_idx > 1 then
            love.graphics.draw(texture, quads[armor_indices[armor_idx]], x, y, 0)
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

    local prevArmor = function(self) armor_idx = (armor_idx - 1) % #armor_indices end

    local nextArmor = function(self) armor_idx = (armor_idx % #armor_indices) + 1 end

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
        prevArmor           = prevArmor,
        nextArmor           = nextArmor,
        setArmorIndex       = setArmorIndex,
        setHelmetIndex      = setHelmetIndex,
        setEyebrowIndex     = setEyebrowIndex,
        setAccessoryIndex   = setAccessoryIndex,
    }, Portrait)
end

return setmetatable(Portrait, {
    __call = function(_, ...) return Portrait.new(...) end,
})
