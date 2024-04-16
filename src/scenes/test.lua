local Test = {}

local makeButton = function(action, ...)
    local widget = ActionBarButton(action)
    return Elem(widget, ...)
end

local makeFlex = function(...)
    return Elem(FlexSpace(), ...)
end

local makeView = function(color, ...)
    local widget = View(color)
    return Elem(widget, ...)
end

local function eachElement(layout, fn)
    local layout_type = getmetatable(layout)
    if layout_type == Elem then
        fn(layout.widget, layout.rect.x, layout.rect.y, layout.rect.w, layout.rect.h)
    elseif layout_type == VStack or layout_type == HStack or layout_type == Border then
        for _, child in ipairs(layout.children) do
            eachElement(child, fn)
        end
    else
        error('invalid layout type', layout_type)
    end
end

-- TODO: add utility function to get each child element from a layout, border, vstack,

Test.new = function()
    local frame = { 0, 0, 0, 0 }

    local vstack1 = VStack({
        makeView({ 1.0, 0.0, 1.0, 1.0}, Stretch(1)),
        HStack(Stretch(1, 0), MinSize(0, 48), {
            makeButton('inventory', MinSize(48)),
            makeFlex(Stretch(1)),
            makeButton('cast-spell', MinSize(48)),
        })
    })

    local layout = Border(Margin(0), { vstack1 })
    print(layout)

    layout:reshape(0, 0, WINDOW_W, WINDOW_H)
    eachElement(layout, function(widget, x, y, w, h)
        print('resize widget', widget, x, y, w, h)
        if getmetatable(widget) == FlexSpace then
            print('FLEX', x, y, w, h)
        elseif getmetatable(widget) == ActionBarButton then
            print('BUTTON', x, y, w, h)
        else
            print('?', x, y, w, h)
        end
        widget:setFrame(x, y, w, h)
    end)

    local setFrame = function(self, x, y, w, h)
        frame = { x, y, w, h }
    end

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
        local x, y, w, h = unpack(frame)
        love.graphics.rectangle('line', x + 1.0, y + 1.0, w - 1.0, h - 1.0)

        eachElement(layout, function(widget) 
            widget:draw()
        end)
    end
    
    return setmetatable({
        draw = draw,
        update = update,
        setFrame = setFrame,
    }, Test)
end

return setmetatable(Test, {
    __call = function(_, ...) return Test.new(...) end,
})
