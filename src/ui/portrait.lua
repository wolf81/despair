--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local lrandom = love.math.random

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
    ['female']  = { 0, 27, 28, 29, 30, 31, 32, 44, 45, 46, 104 },
}

local EYEBROWS_INDICES = { 24, 25, 26, 81, 82, 83, 84, 85, 86 }

local BEARD_INDICES = {
    ['male']    = { 0, 76, 77, 78, 79, 80, 87, 88, 89, 90, 105, 106, 107, 108, 109, 110 },
    ['female']  = { 0 },
}

-- earrings: 20, 21, 22
-- not using horns
local ACCESSORY_INDICES = {
    ['fighter'] = { 0, 9, 13, 23, 111, 112, 114, 115, 123, 124 },
    ['cleric']  = { 0, 8, 48, 49, 50, 75, 111, 112 },
    ['rogue']   = { 0, 9, 10, 13, 23, 20, 111, 112, 114, 115, 121 },
    ['mage']    = { 0, 48, 49, 50, 75, 111, 112, 122 },
}

local HELM_INDICES = {
    ['fighter'] = { 0, 66 },
    ['cleric']  = { 0, 70 },
    ['rogue']   = { 0, 67, 68, 69 },
    ['mage']    = { 0, 71, 72 }
}

local ARMOR_INDICES = {
    ['fighter'] = { 0, 1, 2, 3, 4, 19, 113, 119, 120 },
    ['cleric']  = { 0, 14, 15, 16 },
    ['rogue']   = { 0, 125, 126, 127 },
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

    local accessory_indices = ACCESSORY_INDICES[class]
    local beard_indices = BEARD_INDICES[gender]
    local armor_indices = ARMOR_INDICES[class]
    local hair_indices = HAIR_INDICES[gender]
    local helm_indices = HELM_INDICES[class]

    local face_idx = FACE_INDICES[race..'-'..gender]
    local hair_idx, beard_idx, armor_idx, helm_idx, eyebrows_idx, accessory_idx = 1, 1, 1, 1, 1, 1

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, background_quad, x, y, 0)

        love.graphics.draw(texture, quads[face_idx], x, y, 0)

        if eyebrows_idx > 1 then
            love.graphics.draw(texture, quads[EYEBROWS_INDICES[eyebrows_idx]], x, y, 0)
        end

        if armor_idx > 1 then
            love.graphics.draw(texture, quads[armor_indices[armor_idx]], x, y, 0)
        end

        if beard_idx > 1 then
            love.graphics.draw(texture, quads[beard_indices[beard_idx]], x, y, 0)
        end

        if accessory_idx > 1 then
            love.graphics.draw(texture, quads[accessory_indices[accessory_idx]], x, y, 0)
        end

        -- don't show hair when wearing head covering
        if helm_idx == 1 and hair_idx > 1 then
            love.graphics.draw(texture, quads[hair_indices[hair_idx]], x, y, 0)
        end

        if helm_idx > 1 then
            love.graphics.draw(texture, quads[helm_indices[helm_idx]], x, y, 0)
        end

        love.graphics.draw(texture, border_quad, x, y, 0)
    end

    local update = function(self) end

    local getFrame = function(self) return frame:unpack() end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getSize = function(self) return frame:getSize() end

    local prevHair = function(self) hair_idx = (hair_idx - 1) % #hair_indices end

    local nextHair = function(self) hair_idx = (hair_idx % #hair_indices) + 1 end

    local prevBeard = function(self) beard_idx = (beard_idx - 1) % #beard_indices end

    local nextBeard = function(self) beard_idx = (beard_idx % #beard_indices) + 1 end

    local prevArmor = function(self) armor_idx = (armor_idx - 1) % #armor_indices end

    local nextArmor = function(self) armor_idx = (armor_idx % #armor_indices) + 1 end

    local prevHelm = function(self) helm_idx = (helm_idx - 1) % #helm_indices end

    local nextHelm = function(self) helm_idx = (helm_idx % #helm_indices) + 1 end

    local nextEyebrows = function(self) eyebrows_idx = (eyebrows_idx % #EYEBROWS_INDICES) + 1 end

    local prevEyebrows = function(self) eyebrows_idx = (eyebrows_idx - 1) % #EYEBROWS_INDICES end

    local nextAccessory = function(self) accessory_idx = (accessory_idx % #accessory_indices) + 1 end

    local prevAccessory = function(self) accessory_idx = (accessory_idx - 1) % #accessory_indices end

    local random = function(self)
        print(#quads)
        accessory_idx = accessory_indices[lrandom(#accessory_indices)]
        eyebrows_idx = EYEBROWS_INDICES[lrandom(#EYEBROWS_INDICES)]
        armor_idx = armor_indices[lrandom(#armor_indices)]
        beard_idx = beard_indices[lrandom(#beard_indices)]
        helm_idx = helm_indices[lrandom(#helm_indices)]
        hair_idx = hair_indices[lrandom(#hair_indices)]
        print(accessory_idx, eyebrows_idx, armor_idx, beard_idx, helm_idx, hair_idx)
    end

    random(nil)

    return setmetatable({
        -- methods
        draw            = draw,
        update          = update,
        random          = random,
        getSize         = getSize,
        getFrame        = getFrame,
        setFrame        = setFrame,
        prevHair        = prevHair,
        nextHair        = nextHair,
        prevHelm        = prevHelm,
        nextHelm        = nextHelm,
        prevBeard       = prevBeard,
        nextBeard       = nextBeard,
        prevArmor       = prevArmor,
        nextArmor       = nextArmor,
        prevEyebrows    = prevEyebrows,
        nextEyebrows    = nextEyebrows,
        prevAccessory   = prevAccessory,
        nextAccessory   = nextAccessory,        
    }, Portrait)
end

return setmetatable(Portrait, {
    __call = function(_, ...) return Portrait.new(...) end,
})
