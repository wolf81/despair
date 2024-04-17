--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Offense = {}

Offense.new = function(entity, def)
    local equipment = entity:getComponent(Equipment)
    assert(equipment ~= nil, 'missing component: "Equipment"')

    -- stats is optional, but required in player characters
    local stats = entity:getComponent(Stats)
    if entity.type == 'pc' then
        assert(stats ~= nil, 'missing component: "Stats"')
    end

    -- TODO: it should not be possible to have no weapon equipped, mainly important for players, 
    -- maybe humanoids - to use fist weapons if other weapons are unequipped

    local getAttackValue = function(self, weapon, is_dual_wielding)
        assert(weapon ~= nil, 'missing argument: "weapon"')
        local base = weapon and weapon.attack or 0
        local bonus = (is_dual_wielding == true) and -2 or 0

        -- add bonuses for player characters
        if stats ~= nil then
            local str_bonus = stats:getBonus('str')
            local dex_bonus = stats:getBonus('dex')

            if weapon.kind == 'ranged_1h' or weapon.kind == 'ranged_2h' then
                -- for missle weapons add dexterity bonus
                bonus = bonus + dex_bonus
            else 
                -- for melee weapons add strength bonus
                -- for light weapons, fighters & rogues may use dexterity bonus, if higher                
                if weapon.kind == 'light' and 
                    (entity.class == 'fighter' or entity.class == 'rogue') then
                    bonus = bonus + mmax(str_bonus, dex_bonus)
                else
                    bonus = bonus + str_bonus
                end            
            end
        end

        -- add level bonus, if applicable
        local exp_level = entity:getComponent(ExpLevel)
        if exp_level ~= nil then
            bonus = bonus + exp_level:getValue()
        end

        return base + bonus
    end

    local getDamageValue = function(self, weapon, is_crit)
        assert(weapon ~= nil, 'missing argument: "weapon"')

        local base, bonus = 0, self:getDamageBonus(weapon)

        -- calculate weapon damage - critical hits always inflict maximum damage
        if is_crit == true then
            base = ndn.dice(weapon.damage).max()
        else
            base = ndn.dice(weapon.damage).roll()
        end

        local damage_info = {
            weapon = weapon,
            bonus = bonus             
        }

        return mmax(base + bonus, 1), damage_info
    end

    local getDamageBonus = function(self, weapon)
        local bonus = 0

        if stats then
            local str_bonus = stats:getBonus('str')
            bonus = (weapon.kind == '2h' and str_bonus * 2 or str_bonus)
        end

        return bonus
    end

    return setmetatable({
        -- methods
        getAttackValue  = getAttackValue,
        getDamageValue  = getDamageValue,
        getDamageBonus  = getDamageBonus,
    }, Offense)
end

return setmetatable(Offense, {
    __call = function(_, ...) return Offense.new(...) end,
})
