--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, lrandom = math.floor, love.math.random

local MakePortrait = {}

local FACE = {
    ['human-male']      = 61,
    ['human-female']    = 58,
    ['elf-male']        = 56,
    ['elf-female']      = 55,
    ['dwarf-male']      = 60,
    ['dwarf-female']    = 57,
    ['halfling-male']   = 62,
    ['halfling-female'] = 59,
}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

local function generateImageButtonTexture(quad_idx)
    return TextureGenerator.generateImageButtonTexture(24, 24, quad_idx)
end

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

local EYEBROW_INDICES = { 24, 25, 26, 81, 82, 83, 84, 85, 86 }

MakePortrait.new = function(gender, race, class, fn)
    local background = TextureGenerator.generatePanelTexture(220, 286)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

    local overlay, from_scene = Overlay(), nil

    local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local portrait = UI.makePortrait()
    local face_idx = FACE[string.lower(race .. '-' .. gender)]
    portrait.widget:setFaceIndex(face_idx)

    local armor_idx, helmet_idx, eyebrow_idx, accessory_idx = 1, 1, 1, 1

    local showNextHair = function() portrait.widget:nextHair() end

    local showPrevHair = function() portrait.widget:prevHair() end

    local showNextBeard = function() portrait.widget:nextBeard() end

    local showPrevBeard = function() portrait.widget:prevBeard() end

    local armor_indices = ARMOR_INDICES[string.lower(class)]

    local showNextArmor = function()
        armor_idx = (armor_idx % #armor_indices) + 1
        portrait.widget:setArmorIndex(armor_indices[armor_idx])
    end

    local showPrevArmor = function()
        armor_idx = (armor_idx - 1) % #armor_indices
        portrait.widget:setArmorIndex(armor_indices[armor_idx])
    end

    local helmet_indices = HELM_INDICES[string.lower(class)]

    local showNextHelmet = function()
        helmet_idx = (helmet_idx % #helmet_indices) + 1
        portrait.widget:setHelmetIndex(helmet_indices[helmet_idx])
    end

    local showPrevHelmet = function()
        helmet_idx = (helmet_idx - 1) % #helmet_indices
        portrait.widget:setHelmetIndex(helmet_indices[helmet_idx])
    end

    local showPrevEyebrows = function()
        eyebrow_idx = (eyebrow_idx - 1) % #EYEBROW_INDICES
        portrait.widget:setEyebrowIndex(EYEBROW_INDICES[eyebrow_idx])
    end

    local showNextEyebrows = function()
        eyebrow_idx = (eyebrow_idx + 1) % #EYEBROW_INDICES
        portrait.widget:setEyebrowIndex(EYEBROW_INDICES[eyebrow_idx])
    end

    local showPrevAccessory = function()
        accessory_idx = (accessory_idx - 1) % #ACCESSORY_INDICES
        portrait.widget:setAccessoryIndex(ACCESSORY_INDICES[accessory_idx])
    end

    local showNextAccessory = function()
        accessory_idx = (accessory_idx + 1) % #ACCESSORY_INDICES
        portrait.widget:setAccessoryIndex(ACCESSORY_INDICES[accessory_idx])
    end

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), tidy.Stretch(1), {
            UI.makeLabel('MAKE PORTRAIT', { 1.0, 1.0, 1.0, 1.0 }, 'center', 'start'),
            tidy.VStack(tidy.Spacing(2), tidy.Stretch(1), {
                tidy.HStack({
                    UI.makeFlexSpace(),
                    portrait,
                    UI.makeFlexSpace(),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Helmet', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevHelmet, generateImageButtonTexture(375)),
                    UI.makeButton(showNextHelmet, generateImageButtonTexture(373)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Hair', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevHair, generateImageButtonTexture(375)),
                    UI.makeButton(showNextHair, generateImageButtonTexture(373)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Armor', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevArmor, generateImageButtonTexture(375)),
                    UI.makeButton(showNextArmor, generateImageButtonTexture(373)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Beard', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevBeard, generateImageButtonTexture(375)),
                    UI.makeButton(showNextBeard, generateImageButtonTexture(373)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Eyebrows', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevEyebrows, generateImageButtonTexture(375)),
                    UI.makeButton(showNextEyebrows, generateImageButtonTexture(373)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Accessory', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevAccessory, generateImageButtonTexture(375)),
                    UI.makeButton(showNextAccessory, generateImageButtonTexture(373)),
                }),
            }),
            tidy.HStack({
                UI.makeButton(dismiss, generateTextButtonTexture('Cancel')),
                UI.makeFlexSpace(),
                UI.makeButton(dismiss, generateTextButtonTexture('OK')),
            }),
        })
    }):setFrame(frame:unpack())

    local draw = function(self)
        from_scene:draw()
        overlay:draw()

        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        for e in layout:eachElement() do e.widget:draw() end
    end

    local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local enter = function(self, from)
        from_scene = from
        overlay:fadeIn()
    end

    local leave = function(self, to)
        from_scene = nil
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h)

        background = TextureGenerator.generateBorderTexture(w, h)
    end

    local getFrame = function(self) return frame:unpack() end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            dismiss()
        end
    end

    return setmetatable({
        -- methods
        draw        = draw,
        enter       = enter,
        leave       = leave,
        update      = update,
        random      = random,
        setFrame    = setFrame,
        getFrame    = getFrame,
        keyReleased = keyReleased,
    }, MakePortrait)
end

return setmetatable(MakePortrait, {
    __call = function(_, ...) return MakePortrait.new(...) end,
})
