--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Label = {}

Label.new = function(text, color, align)
    text = text or ''
    text_w = FONT:getWidth(text)
    text_h = FONT:getHeight()

    local frame = Rect(0)

    color = color or { 1.0, 1.0, 1.0, 1.0 }

    local update = function(self, dt) end

    local draw = function(self)
        love.graphics.setColor(unpack(color))

        local x, y, w, h = frame:unpack()
        if align == 'right' then
            love.graphics.print(text, x + w - text_w, y)
        elseif align == 'center' then
            love.graphics.print(text, x + mfloor((w - text_w) / 2), y)
        else
            love.graphics.print(text, x, y)
        end
    end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame:unpack() end

    local getSize = function(self) return text_w, text_h end 

    local setText = function(self, text_) 
        text = text_ or '' 
        text_w = FONT:getWidth(text)
    end
    
    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        setText     = setText,
        getSize     = getSize,
        setFrame    = setFrame,
        getFrame    = getFrame,
    }, Label)
end

return setmetatable(Label, {
    __call = function(_, ...) return Label.new(...) end,
})
