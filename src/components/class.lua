--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin = math.min

local Class = {}

Class.new = function(entity, def)
    local class = def['class']
    assert(class ~= nil, 'missing field: "class"')
    assert(CLASSES[class] ~= nil, 'invalid class "' .. class .. '"')

    local level = def['level']
    assert(level ~= nil, 'missing field: "level"')

    -- current exp, resets to 0 every time a new level is gained
    local exp, exp_goal = 0, level * 10

    local levelUp = function(self)
        assert(self:canLevelUp(), 'not enough experience to level up')

        level = level + 1
        exp = 0
        exp_goal = level * 10

        -- increase health
        local health = entity:getComponent(Health)
        local current, total = health:getValue()
        local gain = ndn.dice('1d6').roll()
        health:increase(gain)

        -- increase stats if level can be divided by 3
        if level % 3 == 0 then
            -- TODO: increase STR, DEX or MIND by 1
        end

        -- class specific adjustments
        if class == 'fighter' and level % 5 == 0 then
            -- TODO: increase attack and damage by 1
        elseif class == 'cleric' and level % 2 == 1 then
            -- TODO: add new spells every uneven level
        elseif class == 'mage' then
            -- TODO: add new spells every uneven level
        end

        Signal.emit('level-up', entity)
    end

    local addExp = function(self, exp_)
        -- if current exp matches goal, no more gain possible, need to increase level first
        if self:canLevelUp() then return end

        exp = mmin(exp + exp_, exp_goal)

        if exp == exp_goal then
            Signal.emit('level-up', entity)
            Signal.emit('notify', 
                StringHelper.capitalize(entity.name) .. ' gained enough experience to advance to level ' .. level + 1)
        end
    end

    local getExp = function(self) return exp, exp_goal end

    local canLevelUp = function(self) return exp == exp_goal end

    local getLevel = function(self) return level end

    return setmetatable({
        -- methods
        canLevelUp  = canLevelUp,
        getLevel    = getLevel,
        levelUp     = levelUp,
        addExp      = addExp,
        getExp      = getExp,
    }, Class)
end

return setmetatable(Class, {
    __call = function(_, ...) return Class.new(...) end,
})
