--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Weapon = {}

Weapon.new = function(entity, def)
    local equipment = entity:getComponent(Equipment)
    assert(equipment ~= nil, 'component missing: "Equipment"')

    local stats = entity:getComponent(Stats)
    local exp_level = entity:getComponent(ExpLevel)

    -- TODO: it should not be possible to have no weapon equipped, mainly important for players, 
    -- maybe humanoids - to use fist weapons if other weapons are unequipped

    local getAttack = function(self)
        local weapon = equipment:getItem('mainhand')
        local base = weapon ~= 0 and weapon.attack or 0
        local bonus = 0

        -- add strength or dexterity bonus for player characters
        if stats ~= nil then
            local str_bonus = stats:getBonus('str')

            if weapon.kind == 'light' and 
                (entity.class == 'fighter' or entity.class == 'rogue') then
                bonus = bonus + mmax(str_bonus, stats:getBonus('dex'))
            else
                bonus = bonus + str_bonus
            end
        end

        -- add experience level bonus, if applicable
        if exp_level ~= nil then
            bonus = bonus + exp_level:getValue()
        end

        return base + bonus
    end

    local getDamage = function(self, is_crit)
        is_crit = (is_crit == true) or false

        local base, bonus = 0, 0

        -- calculate weapon damage - critical hits always inflict maximum damage
        local weapon = equipment:getItem('mainhand')
        if weapon ~= nil then 
            if is_crit then
                base = ndn.dice(weapon.damage).max()
            else
                base = ndn.dice(weapon.damage).roll()
            end
        end

        if stats ~= nil then
            local str_bonus = stats:getBonus('str')
            bonus = bonus + (weapon.kind == '2h' and str_bonus * 2 or str_bonus)
        end

        return mmax(base + bonus, 1)
    end

    return setmetatable({
        -- methods
        getAttack   = getAttack,
        getDamage   = getDamage,
    }, Weapon)
end

return setmetatable(Weapon, {
    __call = function(_, ...) return Weapon.new(...) end,
})
