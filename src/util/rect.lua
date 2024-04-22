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
        getPosition = getPosition,
        contains    = contains,
        getSize     = getSize,
        unpack      = unpack,
    }, Rect)
end

return setmetatable(Rect, {
    __call = function(_, ...) return Rect.new(...) end,
})
