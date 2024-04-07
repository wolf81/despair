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

    -- TODO: it should not be possible to have no weapon equipped, mainly important for players, 
    -- maybe humanoids - to use fist weapons if other weapons are unequipped

    local getAttackValue = function(self)
        local weapon = equipment:getItem('mainhand')
        local base = weapon ~= nil and weapon.attack or 0
        local bonus = 0

        -- add bonuses for player characters
        local stats = entity:getComponent(Stats)
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

    local getDamageValue = function(self, is_crit)
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

        local stats = entity:getComponent(Stats)
        if stats ~= nil then
            local str_bonus = stats:getBonus('str')
            bonus = bonus + (weapon.kind == '2h' and str_bonus * 2 or str_bonus)
        end

        local damage_info = {
            weapon = weapon and weapon.damage or nil, 
            bonus = bonus             
        }

        return mmax(base + bonus, 1), damage_info
    end

    return setmetatable({
        -- methods
        getAttackValue  = getAttackValue,
        getDamageValue  = getDamageValue,
    }, Offense)
end

return setmetatable(Offense, {
    __call = function(_, ...) return Offense.new(...) end,
})
