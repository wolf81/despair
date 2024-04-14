--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local PlayerInfo = {}

PlayerInfo.new = function(player)
    local health_bar = ResourceBar(player, 'health')
    local energy_bar = ResourceBar(player, 'energy')

    local bar_w, bar_h = health_bar:getSize()

    local cartographer = player:getComponent(Cartographer)

    local background = TextureGenerator.generatePanelTexture(INFO_PANEL_W, WINDOW_H - ACTION_BAR_H)

    local update = function(self, dt)
        health_bar:update(dt)
        energy_bar:update(dt)
    end

    local draw = function(self, x, y, w, h)
        love.graphics.setFont(FONT)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.draw(background, WINDOW_W - INFO_PANEL_W, 1)

        local bar_x = x + 15
        local bar_y = 20
        love.graphics.print("HEALTH", bar_x, bar_y)
        health_bar:draw(bar_x, bar_y + 10)
        love.graphics.print("HUNGER", bar_x + 60, bar_y)
        energy_bar:draw(bar_x + 60, bar_y + 10)

        local chart = cartographer:getChart()
        local chart_w, _ = chart:getSize()
        local chart_x = mfloor((w - chart_w) / 2)

        chart:draw(x + chart_x, 50)
    end

    local getSize = function()
        return INFO_PANEL_W, WINDOW_H - ACTION_BAR_H
    end

    return setmetatable({
        -- methods
        update  = update,
        draw    = draw,
    }, PlayerInfo)
end

return setmetatable(PlayerInfo, {
    __call = function(_, ...) return PlayerInfo.new(...) end,
})
