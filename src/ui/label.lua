--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Label = {}

Label.new = function(text, color)
    text = text or ''

    local frame = Rect(0)

    color = color or { 1.0, 1.0, 1.0, 1.0 }

    local update = function(self, dt) end

    local draw = function(self)
        love.graphics.setColor(unpack(color))

        local x, y, w, h = frame:unpack()
        love.graphics.print(text, x, y)
    end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame:unpack() end

    local getSize = function(self) return FONT:getWidth(text), FONT:getHeight() end 

    local setText = function(self, text_) text = text_ or '' end
    
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
