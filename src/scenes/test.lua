local Border, VStack, HStack, Elem = composer.Border, composer.VStack, composer.HStack, composer.Elem
local Stretch, MinSize, Margin = composer.Stretch, composer.MinSize, composer.Margin

local Test = {}

local makeButton = function(action, ...)
    return Elem(ActionBarButton(action), ...)
end

local makeFlex = function()
    return Elem(FlexSpace(), Stretch(1))
end

local makeView = function(color, ...)
    return Elem(View(color), ...)
end

-- TODO: add utility function to get each child element from a layout, border, vstack,

Test.new = function()
    -- configure layout
    local layout = VStack({
        makeView({ 1.0, 0.0, 1.0, 1.0}, Stretch(1)),
        HStack(Stretch(1, 0), MinSize(0, 48), {
            makeFlex(),
            makeButton('inventory', MinSize(48)),
            makeButton('cast-spell', MinSize(48)),
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
