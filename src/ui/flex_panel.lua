--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local FlexPanel = {}

FlexPanel.new = function()
    local frame = Rect(0)

    -- TODO: use dummy texture
    local background = nil

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        if not background then return end

        local x, y, w, h = frame:unpack()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.rectangle('fill', x, y, w, h)
        love.graphics.draw(background, x, y)
    end 

    local setFrame = function(self, x, y, w, h)
        frame = Rect(x, y, w, h)

        if w > 0 and h > 0 then
            background = TextureGenerator.generatePanelTexture(w, h)
        end
    end

    local getSize = function(self) return frame:getSize() end

    return setmetatable({
        setFrame = setFrame,
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, FlexPanel)
end

return setmetatable(FlexPanel, {
    __call = function(_, ...) return FlexPanel.new(...) end,
})
