--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local ChooseOption = {}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

ChooseOption.new = function(title, fn, ...)
    assert(fn ~= nil, 'missing argument: "fn"')
    assert(type(fn) == 'function', 'invalid argument for "fn", expected: "function"')

    local options = {...}

    local background = TextureGenerator.generatePanelTexture(240, 210)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

    local overlay, from_scene = Overlay()

    local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), tidy.Stretch(1), {
            UI.makeLabel(title, { 1.0, 1.0, 1.0, 1.0 }, 'center', 'start'),
            UI.makeChooser(function(item) fn(item:getText()) end, ...),
            tidy.HStack({
                UI.makeButton(dismiss, generateTextButtonTexture('Cancel')),
                UI.makeFlexSpace(),
                UI.makeButton(dismiss, generateTextButtonTexture('OK')),
            }),
        })
    }):setFrame(frame:unpack())

    local from_scene = nil

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

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            overlay:fadeOut(Gamestate.pop)
        end
    end

    return setmetatable({
        -- methods
        draw            = draw,
        leave           = leave,
        enter           = enter,
        update          = update,
        keyReleased     = keyReleased,
    }, ChooseOption)
end

return setmetatable(ChooseOption, {
    __call = function(_, ...) return ChooseOption.new(...) end,
})
