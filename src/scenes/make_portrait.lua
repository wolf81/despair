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
    return TextureGenerator.generateButtonTexture(80, 32, title)
end

MakePortrait.new = function(gender, race, fn)
    local background = TextureGenerator.generatePanelTexture(240, 210)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

    local overlay, from_scene = Overlay(), nil

    local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local portrait = {
        face = FACE[string.lower(gender .. '_' .. race)],
    }

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), tidy.Stretch(1), {
            UI.makeLabel('MAKE PORTRAIT', { 1.0, 1.0, 1.0, 1.0 }, 'center', 'start'),
            tidy.HStack({
                UI.makePortrait(2),
                UI.makeFlexSpace(),
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
