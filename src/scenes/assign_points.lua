--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local AssignPoints = {}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

local function generateImageButtonTexture(quad_idx)
    return TextureGenerator.generateImageButtonTexture(24, 24, quad_idx)
end

-- TODO: should perhaps be called assign stats (?)
AssignPoints.new = function(title, fn, points_info, remaining)
    local frame = Rect(0)

    local background = TextureGenerator.generatePanelTexture(240, 126 + #points_info * 24 + 4 * (#points_info - 1))
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

    local overlay = Overlay()

    local from_scene = nil

    local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local confirm = function() 
        if fn then 
            -- TODO: return the diff of original points and added points (?)
            -- we need to clean-up NewPlayer and LevelUp scenes afterwards
            local points = {}
            for _, point_info in ipairs(points_info) do
                table.insert(points, point_info.value)
            end
            fn(unpack(points))
        end
        dismiss()
    end

    local value_labels = {}
    for idx, point_info in ipairs(points_info) do
        table.insert(value_labels, 
            UI.makeLabel(point_info.value, { 1.0, 1.0, 1.0, 1.0 }, 'end', 'center'))
    end
    table.insert(value_labels, UI.makeLabel(remaining, { 1.0, 1.0, 1.0, 1.0 }, 'end'))

    local incrementValue = function(idx)
        if remaining == 0 then return end

        local point_info = points_info[idx]
        local value = math.min(point_info.max, math.max(point_info.min, point_info.value + 1))
        if value ~= point_info.value then
            point_info.value = value
            value_labels[idx].widget:setText(point_info.value)

            remaining = remaining - 1
            value_labels[#value_labels].widget:setText(remaining)
        end
    end

    local decrementValue = function(idx)
        local point_info = points_info[idx]
        local value = math.min(point_info.max, math.max(point_info.min, point_info.value - 1))
        if value ~= point_info.value then
            point_info.value = value
            value_labels[idx].widget:setText(point_info.value)

            remaining = remaining + 1
            value_labels[#value_labels].widget:setText(remaining)
        end
    end

    local items = {}
    for idx, point_info in ipairs(points_info) do
        table.insert(items, tidy.HStack({ 
            UI.makeLabel(point_info.key, { 1.0, 1.0, 1.0, 1.0 }, 'left', 'center'),
            tidy.HStack(tidy.Spacing(4), {
                value_labels[idx],
                UI.makeFixedSpace(2, 0),
                UI.makeButton(function() decrementValue(idx) end, generateImageButtonTexture(380)),
                UI.makeButton(function() incrementValue(idx) end, generateImageButtonTexture(379)),
            }),
        }))
    end

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), {            
            UI.makeLabel(title, { 1.0, 1.0, 1.0, 1.0 }, 'center', 'center'),
            tidy.VStack(tidy.Stretch(1, 0), tidy.Spacing(4), items),
            tidy.Border(tidy.Margin(0, 10, 0, 10), {                
                tidy.HStack(tidy.Stretch(1, 0), {
                    UI.makeLabel('Points remaining'),
                    UI.makeFlexSpace(),
                    value_labels[#value_labels],
                }),
            }),
            tidy.HStack({
                UI.makeButton(dismiss, generateTextButtonTexture('Cancel')),
                UI.makeFlexSpace(),
                UI.makeButton(confirm, generateTextButtonTexture('OK')),
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
