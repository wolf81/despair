--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local AssignPoints = {}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateButtonTexture(80, 32, title)
end

AssignPoints.new = function(title, points_info, remaining)
    local frame = Rect(0)

    local background = TextureGenerator.generatePanelTexture(240, 100 + #points_info * 20)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

    local overlay = Overlay()

    local from_scene = nil

    local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local items = {}
    for _, point_info in ipairs(points_info) do
        table.insert(items, tidy.HStack(tidy.MinSize(0, 10), { 
            UI.makeLabel(point_info.key),
            UI.makeFlexSpace(),
            UI.makeLabel(point_info.value, { 1.0, 1.0, 1.0, 1.0 }, 'right'),
        }))
    end

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), {            
            UI.makeLabel(title, { 1.0, 1.0, 1.0, 1.0 }, 'center'),
            tidy.VStack(tidy.Stretch(1, 0), tidy.Spacing(10), items),
            tidy.Border(tidy.Margin(0, 10, 0, 10), {                
                tidy.HStack(tidy.Stretch(1, 0), {
                    UI.makeLabel('Points remaining'),
                    UI.makeFlexSpace(),
                    UI.makeLabel(remaining, { 1.0, 1.0, 1.0, 1.0 }, 'right'),
                }),
            }),
            tidy.HStack({
                UI.makeButton(dismiss, generateTextButtonTexture('Cancel')),
                UI.makeFlexSpace(),
                UI.makeButton(dismiss, generateTextButtonTexture('OK')),
            }),
        }),
    }):setFrame(frame:unpack())

    local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local draw = function(self)
        from_scene:draw()
        overlay:draw()

        local x, y, w, h = frame:unpack()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        for e in layout:eachElement() do e.widget:draw() end
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
        draw            = draw,
        enter           = enter,
        leave           = leave,
        update          = update,
        setFrame        = setFrame,
        getFrame        = getFrame,
        keyReleased     = keyReleased,
    }, AssignPoints)
end

return setmetatable(AssignPoints, {
    __call = function(_, ...) return AssignPoints.new(...) end,
})
