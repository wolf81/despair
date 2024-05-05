--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local MakePortrait = {}

local FACE = {
    ['human-male'] = 61,
    ['human-female'] = 58,
    ['elf-male'] = 56,
    ['elf-female'] = 55,
    ['dwarf-male'] = 60,
    ['dwarf-female'] = 57,
    ['halfling-male'] = 62,
    ['halfling-female'] = 59,
}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

local function generateImageButtonTexture(quad_idx)
    return TextureGenerator.generateImageButtonTexture(24, 24, quad_idx)
end

local HAIR_INDICES = { 0, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
    46, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, }

local BEARD_INDICES = { 0, 76, 77, 78, 79, 80, 87, 88, 89, 90, 105, 106, 107, 108, 109, 110 }

local HELM_INDICES = {
    ['fighter'] = { 0, 66, },
    ['cleric']  = { 0, 70, },
    ['rogue']   = { 0, 67, 68, 69, },
    ['mage']    = { 0, 71, 72, }
}
local ARMOR_INDICES = {
    ['fighter'] = { 0, 1, 2, 3, 4, },
    ['cleric']  = { 0, 14, 15, 16, },
    ['rogue']   = { 0, 125, 126, 127, },
    ['mage']    = { 0, 17, 18, 116, 117, 118 }
}

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

    local hair_idx, beard_idx, armor_idx, helmet_idx = 0, 0, 0, 0

    local showNextHair = function()
        hair_idx = (hair_idx % #HAIR_INDICES) + 1
        portrait.widget:setHairIndex(HAIR_INDICES[hair_idx])
    end

    local showPrevHair = function()
        hair_idx = (hair_idx % #HAIR_INDICES) - 1
        portrait.widget:setHairIndex(HAIR_INDICES[hair_idx])
    end

    local showNextBeard = function()
        beard_idx = (beard_idx % #BEARD_INDICES) + 1
        portrait.widget:setBeardIndex(BEARD_INDICES[beard_idx])
    end

    local showPrevBeard = function()
        beard_idx = (beard_idx % #BEARD_INDICES) - 1
        portrait.widget:setBeardIndex(BEARD_INDICES[beard_idx])
    end

    local armor_indices = ARMOR_INDICES[string.lower(class)]

    local showNextArmor = function()
        armor_idx = (armor_idx % #armor_indices) + 1
        portrait.widget:setArmorIndex(armor_indices[armor_idx])
    end

    local showPrevArmor = function()
        armor_idx = (armor_idx % #armor_indices) - 1
        portrait.widget:setArmorIndex(armor_indices[armor_idx])
    end

    local helmet_indices = HELM_INDICES[string.lower(class)]

    local showNextHelmet = function()
        helmet_idx = (helmet_idx % #helmet_indices) + 1
        portrait.widget:setHelmetIndex(helmet_indices[helmet_idx])
    end

    local showPrevHelmet = function()
        helmet_idx = (helmet_idx % #helmet_indices) - 1
        portrait.widget:setHelmetIndex(helmet_indices[helmet_idx])
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
                    UI.makeLabel('Accessory 1', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(dismiss, generateImageButtonTexture(375)),
                    UI.makeButton(dismiss, generateImageButtonTexture(373)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Accessory 2', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(dismiss, generateImageButtonTexture(375)),
                    UI.makeButton(dismiss, generateImageButtonTexture(373)),
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
        setFrame    = setFrame,
        getFrame    = getFrame,
        keyReleased = keyReleased,
    }, MakePortrait)
end

return setmetatable(MakePortrait, {
    __call = function(_, ...) return MakePortrait.new(...) end,
})
