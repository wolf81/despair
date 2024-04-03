local mfloor = math.floor

local PlayerInfo = {}

PlayerInfo.new = function(player)
    local portrait = Portrait(player)
    local portrait_w, portrait_h = portrait:getSize() 

    local font = love.graphics.newImageFont('gfx/image_font.png', FONT_CHARS)
    love.graphics.setFont(font)

    local update = function(self)
        -- body
    end

    local draw = function(self, x, y, w, h)
        love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
        love.graphics.rectangle('fill', x, y, w, h)

        love.graphics.setLineWidth(1.0)
        love.graphics.setColor(0.3, 0.3, 0.3, 1.0)
        love.graphics.line(x + 0.5, 0, x + 0.5, h)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
        portrait:draw(x + mfloor((w - portrait_w) / 2), 20)

        local stats = player:getComponent(Stats)

        local ox = x + 40
        local oy = portrait_h + 40
        love.graphics.print("STR:  " .. stats:getValue('str'), ox, oy)
        love.graphics.print("DEX:  " .. stats:getValue('dex'), ox, oy + 20)
        love.graphics.print("MIND: " .. stats:getValue('mind'), ox, oy + 40)

        local skills = player:getComponent(Skills)
        love.graphics.print("PHYS: " .. skills:getValue('phys'), ox, oy + 80)
        love.graphics.print("SUBT: " .. skills:getValue('subt'), ox, oy + 100)
        love.graphics.print("KNOW: " .. skills:getValue('know'), ox, oy + 120)
        love.graphics.print("COMM: " .. skills:getValue('comm'), ox, oy + 140)
 
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
