--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local ExpLevel = {}

ExpLevel.new = function(entity, def)
    local level = def['level']

    local exp = def['exp'] or 0

    local incLevel = function(self)
        level = level + 1
        print('advanced to level: ' .. level)
        return level
    end

    local addExp = function(self, exp_) exp = exp + exp_ end

    local getExp = function(self) return exp end

    local getLevel = function(self) return level end

    return setmetatable({
        -- methods
        incLevel    = incLevel,
        getLevel    = getLevel,
        addExp      = addExp,
        getExp      = getExp,
    }, ExpLevel)
end

return setmetatable(ExpLevel, {
    __call = function(_, ...) return ExpLevel.new(...) end,
})
