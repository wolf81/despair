--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local ExpLevel = {}

ExpLevel.new = function(entity, def)
    local value = def['level']

    local advance = function(self)
        value = value + 1
        print('advanced to level: ' .. value)
        return value
    end

    local getValue = function(self)
        return value
    end

    return setmetatable({
        --methods
        advance     = advance,
        getValue    = getValue,
    }, ExpLevel)
end

return setmetatable(ExpLevel, {
    __call = function(_, ...) return ExpLevel.new(...) end,
})
