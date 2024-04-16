local Test = {}

local makeButton = function(action)
    return tidy.Elem(ActionBarButton(action), tidy.MinSize(48), tidy.Stretch(0))
end

local makeFlex = function()
    return tidy.Elem(FlexSpace(), tidy.Stretch(1))
end

local makeView = function(color)
    return tidy.Elem(View(color), tidy.Stretch(1))
end

-- TODO: add utility function to get each child element from a layout, border, vstack,

Test.new = function()
    -- configure layout
    local layout = tidy.VStack({
        makeView({ 1.0, 0.0, 1.0, 1.0}),
        tidy.HStack(tidy.Stretch(1, 0), tidy.MinSize(0, 48), {
            makeFlex(),
            makeButton('inventory'),
            makeButton('cast-spell'),
            makeFlex(),
        })
    })

    -- update layout for window size
    layout:setFrame(0, 0, WINDOW_W, WINDOW_H)
    for e in layout:eachElement() do
        e.widget:setFrame(e.rect:unpack())
    end

    local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local draw = function(self)
        for e in layout:eachElement() do e.widget:draw() end
    end
    
    return setmetatable({
        draw = draw,
        update = update,
    }, Test)
end

return setmetatable(Test, {
    __call = function(_, ...) return Test.new(...) end,
})
