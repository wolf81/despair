local FlexSpace = {}

FlexSpace.new = function(w, h)
    local background = TextureGenerator.generatePanelTexture(w, h)

    local update = function(self, dt)
        -- body
    end

    local draw = function(self, x, y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)
    end 

    local getSize = function(self) return w, h end

    return setmetatable({
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, FlexSpace)
end

return setmetatable(FlexSpace, {
    __call = function(_, ...) return FlexSpace.new(...) end,
})
