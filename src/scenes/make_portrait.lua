--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, lrandom = math.floor, love.math.random

local MakePortrait = {}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

local function generateImageButtonTexture(quad_idx)
    return TextureGenerator.generateImageButtonTexture(24, 24, quad_idx)
end

MakePortrait.new = function(gender, race, class, fn)
    local background = TextureGenerator.generatePanelTexture(220, 286)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

    local overlay, from_scene = Overlay(), nil

    local portrait = UI.makePortrait(gender, race, class)

    local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local confirm = function() 
        if fn then fn(portrait.widget:getImage()) end
        dismiss()
    end

    local showNextHair = function() portrait.widget:nextHair() end

    local showPrevHair = function() portrait.widget:prevHair() end

    local showNextBeard = function() portrait.widget:nextBeard() end

    local showPrevBeard = function() portrait.widget:prevBeard() end

    local showNextArmor = function() portrait.widget:nextArmor() end

    local showPrevArmor = function() portrait.widget:prevArmor() end

    local showNextHelm = function() portrait.widget:nextHelm() end

    local showPrevHelm = function() portrait.widget:prevHelm() end

    local showPrevEyebrows = function() portrait.widget:prevEyebrows() end

    local showNextEyebrows = function() portrait.widget:nextEyebrows() end

    local showPrevAccessory = function() portrait.widget:prevAccessory() end

    local showNextAccessory = function() portrait.widget:nextAccessory() end

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
                    UI.makeButton(showPrevHelm, generateImageButtonTexture(378)),
                    UI.makeButton(showNextHelm, generateImageButtonTexture(376)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Hair', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevHair, generateImageButtonTexture(378)),
                    UI.makeButton(showNextHair, generateImageButtonTexture(376)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Armor', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevArmor, generateImageButtonTexture(378)),
                    UI.makeButton(showNextArmor, generateImageButtonTexture(376)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Beard', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevBeard, generateImageButtonTexture(378)),
                    UI.makeButton(showNextBeard, generateImageButtonTexture(376)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Eyebrows', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevEyebrows, generateImageButtonTexture(378)),
                    UI.makeButton(showNextEyebrows, generateImageButtonTexture(376)),
                }),
                tidy.HStack(tidy.Spacing(2), { 
                    UI.makeLabel('Accessory', { 1.0, 1.0, 1.0, 1.0 }, 'start', 'center'),
                    UI.makeFlexSpace(),
                    UI.makeButton(showPrevAccessory, generateImageButtonTexture(378)),
                    UI.makeButton(showNextAccessory, generateImageButtonTexture(376)),
                }),
            }),
            tidy.HStack({
                UI.makeButton(dismiss, generateTextButtonTexture('Cancel')),
                UI.makeFlexSpace(),
                UI.makeButton(confirm, generateTextButtonTexture('OK')),
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

    local getImage = function(self) return portrait.widget:getImage() end

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
        getImage    = getImage,
        keyReleased = keyReleased,
    }, MakePortrait)
end

return setmetatable(MakePortrait, {
    __call = function(_, ...) return MakePortrait.new(...) end,
})
