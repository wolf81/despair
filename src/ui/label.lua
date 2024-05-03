--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Label = {}

Label.new = function(text, color, align)
    local text_info = {
        text    = text or '',
        width   = FONT:getWidth(text),
        height  = FONT:getHeight(),
    }

    local frame = Rect(0)

    color = color or { 1.0, 1.0, 1.0, 1.0 }

    local update = function(self, dt) end

    local draw = function(self)
        love.graphics.setColor(unpack(color))

        local x, y, w, h = frame:unpack()
        local oy = mfloor(text_info.height / 4)
        if align == 'right' then
            love.graphics.print(text_info.text, x + w - text_info.width, y + oy)
        elseif align == 'center' then
            love.graphics.print(text, x + mfloor((w - text_info.width) / 2), y + oy)
        else
            love.graphics.print(text, x, y + oy)
        end
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 
    end

    local getFrame = function(self) return frame:unpack() end

    local getSize = function(self) return text_info.width, text_info.height end 

    local setText = function(self, text_) 
        text_info.text = text_ or ''
        text_info.width = FONT:getWidth(text_)
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
