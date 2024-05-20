--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Rect = {}

Rect.new = function(x, y, w, h)
    x = x or 0
    y = y or x
    w = w or 0
    h = h or w

    local contains = function(self, px, py)
        return px > x and px < x + w and py > y and py < y + h
    end

    local unpack = function(self) return x, y, w, h end

    local getPosition = function(self) return x, y end

    local getSize = function(self) return w, h end

    return setmetatable({
        -- methods        
        unpack      = unpack,
        getSize     = getSize,
        contains    = contains,
        getPosition = getPosition,
    }, Rect)
end

function Rect.__eq(self, other)
    local x1, y1, w1, h1 = self:unpack()
    local x2, y2, w2, h2 = other:unpack()
    return x1 == x2 and y1 == y2 and w1 == w2 and h1 == h2
end

return setmetatable(Rect, {
    __call = function(_, ...) return Rect.new(...) end,
})
