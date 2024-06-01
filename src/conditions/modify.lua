--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Modify = {}

Modify.new = function(key, prop, value, exp_time)
    local icon = nil

    local isExpired = function(self, time) return time > exp_time end

    local getKey = function(self) return key end

    local getProperty = function(self) return prop end

    local getValue = function(self) return value end

    local getIcon = function(self) return icon end

    local setIcon = function(self, icon_) icon = icon_ end

    return setmetatable({
        -- methods
        getKey      = getKey,
        getIcon     = getIcon,
        setIcon     = setIcon,
        getValue    = getValue,
        isExpired   = isExpired,
        getProperty = getProperty,
    }, Modify)
end

return setmetatable(Modify, {
    __call = function(_, ...) return Modify.new(...) end,
})
