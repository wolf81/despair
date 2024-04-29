local Parchment = {}

Parchment.new = function(text)
    local background = nil

    local frame = Rect(0)

    local label = UI.makeLabel(text, { 0.0, 0.0, 0.0, 0.7 })
    local layout = tidy.Border(tidy.Margin(10), {
        label,
    })

    local draw = function(self)
        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)        

        for e in layout:eachElement() do e.widget:draw() end
    end

    local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local setFrame = function(self, x, y, w, h) 
        background = TextureGenerator.generateParchmentTexture(w, h)

        frame = Rect(x, y, w, h)

        layout:setFrame(x, y, w, h) 
        for e in layout:eachElement() do e.widget:setFrame(e.rect:unpack()) end
    end

    local getFrame = function(self) return frame:unpack() end

    local getSize = function(self) return frame:getSize() end

    local setText = function(self, text) label.widget:setText(text) end
    
    return setmetatable({
        -- methods
        setFrame    = setFrame,
        getFrame    = getFrame,
        setText     = setText,
        getSize     = getSize,
        update      = update,
        draw        = draw,
    }, Parchment)
end

return setmetatable(Parchment, {
    __call = function(_, ...) return Parchment.new(...) end,
})
