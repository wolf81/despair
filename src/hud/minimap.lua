--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Minimap = {}

Minimap.new = function(player)
    local size = 120
    local background = TextureGenerator.generatePaperTexture(size, size)

    local cartographer = player:getComponent(Cartographer)

    local draw = function(self, x, y)
        local w, h = self:getSize()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        local title = "LEVEL " .. cartographer:getLevelIndex()
        local title_x = mfloor((w - FONT:getWidth(title)) / 2)

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.print(title, x + title_x, y + 10)

        local chart = cartographer:getChartImage()
        local chart_w, chart_h = cartographer:getSize()
        local chart_x, chart_y = (w - chart_w) / 2, (h - chart_h) / 2 + 5

        love.graphics.draw(chart, x + chart_x, y + chart_y)
    end

    local getSize = function()
        return background:getDimensions()
    end

    return setmetatable({
        -- methods
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, Minimap)
end

return setmetatable(Minimap, {
    __call = function(_, ...) return Minimap.new(...) end
})
