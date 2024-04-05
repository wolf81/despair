--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local PlayerInfo = {}

PlayerInfo.new = function(player)
    local portrait = Portrait(player)
    local portrait_w, portrait_h = portrait:getSize() 

    local minimap = Minimap(player)
    local minimap_w, minimap_h = minimap:getSize()

    local update = function(self)
        -- body
    end

    local draw = function(self, x, y, w, h)
        love.graphics.setFont(FONT)

        love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
        love.graphics.rectangle('fill', x, y, w, h)

        love.graphics.setLineWidth(1.0)
        love.graphics.setColor(0.3, 0.3, 0.3, 1.0)
        love.graphics.line(x + 0.5, 0, x + 0.5, h)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
        portrait:draw(x + 20, 20)
        -- portrait:draw(x + mfloor((w - portrait_w) / 2), 20)

        local ox = x + 20
        local oy = minimap_h + 40
        local stats = player:getComponent(Stats)
        love.graphics.print("STATS", ox, oy)
        love.graphics.print("STR:  " .. stats:getValue('str'), ox, oy + 20)
        love.graphics.print("DEX:  " .. stats:getValue('dex'), ox, oy + 40)
        love.graphics.print("MIND: " .. stats:getValue('mind'), ox, oy + 60)

        local skills = player:getComponent(Skills)
        love.graphics.print("SKILLS", WINDOW_W - 100, oy)
        love.graphics.print("PHYS: " .. skills:getValue('phys'), WINDOW_W - 100, oy + 20)
        love.graphics.print("SUBT: " .. skills:getValue('subt'), WINDOW_W - 100, oy + 40)
        love.graphics.print("KNOW: " .. skills:getValue('know'), WINDOW_W - 100, oy + 60)
        love.graphics.print("COMM: " .. skills:getValue('comm'), WINDOW_W - 100, oy + 80)

        ox = mfloor((w - minimap_w) / 2)        
        minimap:draw(WINDOW_W - minimap_w - 20, 20)
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
