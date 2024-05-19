--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local lrandom = love.math.random

local Portrait = {}

local ASCII_CHAR_OFFSET = 65 -- start at letter 'A'

local SPACING = 2

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
    local is_hidden = true 

    local texture = TextureCache:get('uf_portraits')
    local quads = QuadCache:get('uf_portraits')

    local quad_w, quad_h = select(3, quads[1]:getViewport())
    local frame = Rect(0, 0, quad_w, quad_h)

    local background_quad, border_quad = quads[6], quads[7]

    local accessory_indices = nil
    local beard_indices = nil
    local armor_indices = nil
    local hair_indices = nil
    local helm_indices = nil

    local face_idx, hair_idx, beard_idx, armor_idx  = 1, 1, 1, 1
    local helm_idx, eyebrows_idx, accessory_idx     = 1, 1, 1

    local image, angle = nil, 0

    local show_level_up = false

    local getImage = function()
        local w, h = select(3, frame:unpack())

        local canvas = love.graphics.newCanvas(w, h)
        canvas:renderTo(function() 
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            love.graphics.draw(texture, background_quad, x, y, 0)

            if not is_hidden then
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

                if show_level_up then
                    local plus_texture = TextureCache:get('uf_interface')
                    local plus_quad = QuadCache:get('uf_interface')[379]
                    local plus_w  = select(3, plus_quad:getViewport()) 
                    love.graphics.draw(plus_texture, plus_quad, w - plus_w - SPACING, SPACING)
                end                
            end

            love.graphics.draw(texture, border_quad, x, y, 0)
        end)

        return canvas
    end

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        if not image then image = getImage() end

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(image, x, y, angle)
    end

    local update = function(self) end

    local getFrame = function(self) return frame:unpack() end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getSize = function(self) return frame:getSize() end

    local prevHair = function(self) 
        hair_idx = (hair_idx - 1) % #hair_indices 
        image = nil
    end

    local nextHair = function(self) 
        hair_idx = (hair_idx % #hair_indices) + 1 
        image = nil
    end

    local prevBeard = function(self) 
        beard_idx = (beard_idx - 1) % #beard_indices 
        image = nil
    end

    local nextBeard = function(self) 
        beard_idx = (beard_idx % #beard_indices) + 1 
        image = nil
    end

    local prevArmor = function(self) 
        armor_idx = (armor_idx - 1) % #armor_indices 
        image = nil
    end

    local nextArmor = function(self) 
        armor_idx = (armor_idx % #armor_indices) + 1 
        image = nil
    end

    local prevHelm = function(self) 
        helm_idx = (helm_idx - 1) % #helm_indices 
        image = nil
    end

    local nextHelm = function(self) 
        helm_idx = (helm_idx % #helm_indices) + 1 
        image = nil
    end

    local nextEyebrows = function(self) 
        eyebrows_idx = (eyebrows_idx % #EYEBROWS_INDICES) + 1 
        image = nil
    end

    local prevEyebrows = function(self) 
        eyebrows_idx = (eyebrows_idx - 1) % #EYEBROWS_INDICES 
        image = nil
    end

    local nextAccessory = function(self) 
        accessory_idx = (accessory_idx % #accessory_indices) + 1 
        image = nil
    end

    local prevAccessory = function(self) 
        accessory_idx = (accessory_idx - 1) % #accessory_indices 
        image = nil
    end

    local random = function(self)
        accessory_idx = lrandom(#accessory_indices)
        eyebrows_idx = lrandom(#EYEBROWS_INDICES)
        armor_idx = lrandom(#armor_indices)
        beard_idx = lrandom(#beard_indices)
        helm_idx = lrandom(#helm_indices)
        hair_idx = lrandom(#hair_indices)
        image = nil
    end

    local getIdentifier = function(self)
        if is_hidden then return nil end
        
        local values = {
            string.char(face_idx + ASCII_CHAR_OFFSET),
            string.char(hair_idx + ASCII_CHAR_OFFSET),
            string.char(helm_idx + ASCII_CHAR_OFFSET),
            string.char(beard_idx + ASCII_CHAR_OFFSET),
            string.char(armor_idx + ASCII_CHAR_OFFSET),
            string.char(eyebrows_idx + ASCII_CHAR_OFFSET),
            string.char(accessory_idx + ASCII_CHAR_OFFSET),
        }
        return table.concat(values, '')
    end

    local setIdentifier = function(self, value)
        if value then
            face_idx = string.byte(string.sub(value, 1, 1)) - ASCII_CHAR_OFFSET
            hair_idx = string.byte(string.sub(value, 2, 2)) - ASCII_CHAR_OFFSET
            helm_idx = string.byte(string.sub(value, 3, 3)) - ASCII_CHAR_OFFSET
            beard_idx = string.byte(string.sub(value, 4, 4)) - ASCII_CHAR_OFFSET
            armor_idx = string.byte(string.sub(value, 5, 5)) - ASCII_CHAR_OFFSET
            eyebrows_idx = string.byte(string.sub(value, 6, 6)) - ASCII_CHAR_OFFSET
            accessory_idx = string.byte(string.sub(value, 7, 7)) - ASCII_CHAR_OFFSET
        end

        is_hidden = (not value)

        image = nil
    end

    local setRotation = function(self, angle_) angle = angle_ or 0 end

    local setShowLevelUp = function(self, flag) 
        show_level_up = (flag == true) 
        image = nil
    end

    local configure = function(self, gender, race, class)
        is_hidden = not (gender or race or class)

        gender = string.lower(gender or 'male')
        race = string.lower(race or 'human')
        class = string.lower(class or 'fighter')

        accessory_indices = ACCESSORY_INDICES[class]
        beard_indices = BEARD_INDICES[gender]
        armor_indices = ARMOR_INDICES[class]
        hair_indices = HAIR_INDICES[gender]
        helm_indices = HELM_INDICES[class]

        face_idx = FACE_INDICES[race..'-'..gender]

        image = nil
    end

    configure(nil, gender, race, class)

    random(nil)

    return setmetatable({
        -- methods
        draw            = draw,
        update          = update,
        random          = random,
        getSize         = getSize,
        getImage        = getImage,
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
        configure       = configure,
        setRotation     = setRotation,
        prevEyebrows    = prevEyebrows,
        nextEyebrows    = nextEyebrows,
        prevAccessory   = prevAccessory,
        nextAccessory   = nextAccessory,        
        getIdentifier   = getIdentifier,
        setIdentifier   = setIdentifier,
        setShowLevelUp  = setShowLevelUp,
    }, Portrait)
end

return setmetatable(Portrait, {
    __call = function(_, ...) return Portrait.new(...) end,
})
