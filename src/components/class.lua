--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin, mfloor = math.min, math.floor

local Class = {}

CLASSES = TableHelper.readOnly({
    ['fighter'] = true,
    ['cleric']  = true,
    ['rogue']   = true,
    ['mage']    = true,
})

ARMOR_PROFICIENCIES = TableHelper.readOnly({
    ['fighter'] = {
        ['shield'] = true,
        ['heavy']  = true,
        ['medium'] = true,
        ['light']  = true,
        ['none']   = true,
    },
    ['cleric'] = {
        ['shield'] = false,
        ['heavy']  = false,
        ['medium'] = true,
        ['light']  = true,
        ['none']   = true,
    },
    ['rogue'] = {
        ['shield'] = false,
        ['heavy']  = false,
        ['medium'] = false,
        ['light']  = true,
        ['none']   = true,
    },
    ['mage'] = {
        ['shield'] = false,
        ['heavy']  = false,
        ['medium'] = false,
        ['light']  = false,
        ['none']   = true,
    },
})

Class.new = function(entity, def)
    local class = def['class']
    assert(class ~= nil, 'missing field: "class"')
    assert(CLASSES[class] ~= nil, 'invalid class "' .. class .. '"')

    local level = def['level']
    assert(level ~= nil, 'missing field: "level"')

    -- current exp, resets to 0 every time a new level is gained
    local exp, exp_goal = 0, level * 10

    -- fighters gain +1 to their attack and damage rolls at levels 5, 10, 15, ...
    local att_bonus, dmg_bonus = 0, 0

    -- cache level-up changes
    local cache = nil

    local levelUp = function(self, is_preview)
        assert(self:canLevelUp(), 'not enough experience to level up')

        local health = entity:getComponent(Health)

        if not cache then
            local level = level + 1
            local att_bonus = 1
            local dmg_bonus = nil

            if class == 'fighter' and level % 5 == 0 then
                att_bonus = att_bonus + 1
                dmg_bonus = 1
            end

            -- for cleric & mage add spells at levels 3, 5, 7, ... (level % 2 == 1)

            cache = {
                level = level,
                hp_gain = ndn.dice('1d6').roll(),
                att_bonus = att_bonus,
                dmg_bonus = dmg_bonus, 
            }
        end

        if not is_preview then
            local stats = entity:getComponent(Stats)
            if stats and stats:getPoints() ~= 0 then
                error('assign ' .. stats:getPoints() .. ' point(s) to any stat')
            end

            level = cache.level
            health:increase(cache.hp_gain)

            exp, exp_goal = 0, level * 10

            Signal.emit('level-up', entity)

            cache = nil
        end

        return cache
    end

    local addExp = function(self, exp_)
        -- if current exp matches goal, no more gain possible, need to increase level first
        if self:canLevelUp() then return end

        exp = mmin(exp + exp_, exp_goal)

        if exp == exp_goal then
            if (level + 1) % 3 == 0 then
                entity:getComponent(Stats):addPoints(1)
            end
            Signal.emit('level-up', entity)
            Signal.emit('notify', 
                StringHelper.capitalize(entity.name) .. ' gained enough experience to advance to level ' .. level + 1)
        end
    end

    local getExp = function(self) return exp, exp_goal end

    local canLevelUp = function(self) return exp == exp_goal end

    local getLevel = function(self) return level end

    local getAttackBonus = function(self) return level + att_bonus end

    local getDamageBonus = function(self) return dmg_bonus end

    local getSkillBonus = function(self, skill)
        if skill == 'phys' then 
            return class == 'fighter' and 3 or 0
        elseif skill == 'know' then 
            return class == 'mage' and 3 or 0
        elseif skill == 'comm' then 
            return class == 'cleric' and 3 or 0
        elseif skill == 'subt' then 
            return class == 'rogue' and 3 or 0
        elseif skill == 'surv' then
            return (class == 'ranger' or class == 'druid') and 3 or 0            
        end

        return 0
    end

    local getClassName = function(self) return class end

    local isAnyOf = function(self, ...)
        local args = {...}
        for _, class_ in ipairs(args) do
            if class == class_ then return true end
        end
        return false
    end

    local canEquip = function(self, item)
        if item.type == 'armor' then
            return ARMOR_PROFICIENCIES[class][item.kind]
        end

        return true
    end

    local canDualWield = function(self)
        return class == 'fighter' or class == 'rogue'
    end

    return setmetatable({
        -- methods
        getExp          = getExp,
        addExp          = addExp,
        levelUp         = levelUp,
        isAnyOf         = isAnyOf,
        getLevel        = getLevel,
        canEquip        = canEquip,
        canLevelUp      = canLevelUp,
        getClassName    = getClassName,
        canDualWield    = canDualWield,
        getSkillBonus   = getSkillBonus,
        getDamageBonus  = getDamageBonus,
        getAttackBonus  = getAttackBonus,
    }, Class)
end

return setmetatable(Class, {
    __call = function(_, ...) return Class.new(...) end,
})
