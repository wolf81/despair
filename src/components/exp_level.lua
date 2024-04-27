--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin = math.min

local ExpLevel = {}

ExpLevel.new = function(entity, def)
    local level = def['level']

    -- for NPCs can use HD count to represent level
    if not level then 
        local hd = def['hd']
        assert(hd ~= nil, 'missing field: "level" or "hd"')
        level = ndn.dice(def['hd']).count()
    end

    -- current exp, resets to 0 every time a new level is gained
    local exp = def['exp'] or 0

    local incLevel = function(self)
        level = level + 1
        exp = 0
        return level
    end

    local addExp = function(self, exp_)
        local _, exp_goal = self:getExp()

        -- if current exp matches goal, no more gain possible, need to increase level first
        if exp == exp_goal then return end

        exp = mmin(exp + exp_, exp_goal)

        if exp == exp_goal then
            Signal.emit('level-up')
            Signal.emit('notify', 
                StringHelper.capitalize(entity.name) .. ' gained enough experience to advance to level ' .. level + 1)
        end
    end

    local getExp = function(self) return exp, level * 2 end

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
