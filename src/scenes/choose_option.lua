--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local ChooseOption = {}

ChooseOption.new = function(title, ...)
    local options = {...}

    local background = TextureGenerator.generatePanelTexture(240, 200)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), {
            UI.makeLabel(title, {1.0, 1.0, 1.0, 1.0}, 'center'),
            UI.makeChooser(...),            
        }),
    }):setFrame(frame:unpack())

    local from_scene = nil

    local draw = function(self)
        from_scene:draw()

        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        for e in layout:eachElement() do e.widget:draw() end
    end

    local update = function(self, dt)
        from_scene:update(0)

        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local enter = function(self, from)
        from_scene = from
    end

    local leave = function(self, to)
        from_scene = nil
    end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            Gamestate.pop()
        end
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        if Gamestate.current() == self and not frame:contains(mx, my) then
            Gamestate.pop()
        end
    end

    return setmetatable({
        -- methods
        draw            = draw,
        leave           = leave,
        enter           = enter,
        update          = update,
        keyReleased     = keyReleased,
        mouseReleased   = mouseReleased,
    }, ChooseOption)
end

return setmetatable(ChooseOption, {
    __call = function(_, ...) return ChooseOption.new(...) end,
})
