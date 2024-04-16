local FlexSpace = {}

FlexSpace.new = function()
    local frame = { 0, 0, 0, 0 }

    -- TODO: use dummy texture
    local background = nil

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        if not background then return end

        local x, y = unpack(frame)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)
    end 

    local setFrame = function(self, x, y, w, h)
        frame = { x, y, w, h }

        if w > 0 and h > 0 then
            background = TextureGenerator.generatePanelTexture(w, h)
        end
    end

    local getSize = function(self) return width, height end

    return setmetatable({
        setFrame = setFrame,
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, FlexSpace)
end

return setmetatable(FlexSpace, {
    __call = function(_, ...) return FlexSpace.new(...) end,
})
