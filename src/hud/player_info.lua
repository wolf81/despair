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

        love.graphics.setColor(0.3, 0.3, 0.3, 1.0)
        love.graphics.line(x + 1, 0, x + 1, h)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
        portrait:draw(x + mfloor((w - portrait_w) / 2), 20)      

        love.graphics.print("This is some awesome text", 100, 100)
 
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
