local FlexSpace = {}

FlexSpace.new = function(width, height)
    assert(width ~= nil, 'missing argument: "width"')
    assert(height ~= nil, 'missing argument: "height"')
    local background = TextureGenerator.generatePanelTexture(width, height)
    width, height = background:getDimensions()

    local update = function(self, dt)
        -- body
    end

    local draw = function(self, x, y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)
    end 

    local getSize = function(self) return width, height end

    return setmetatable({
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, FlexSpace)
end

return setmetatable(FlexSpace, {
    __call = function(_, ...) return FlexSpace.new(...) end,
})
