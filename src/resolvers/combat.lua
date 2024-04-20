--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.resolve = function(entity, target)
    local health = target:getComponent(Health)
    local defense = target:getComponent(Defense)
    local offense = entity:getComponent(Offense)
    local equipment = entity:getComponent(Equipment)

    local eq_mainhand = equipment:getItem('mainhand')
    local eq_offhand = equipment:getItem('offhand')

    local weapons = {}
    if eq_mainhand ~= nil and eq_mainhand.type == 'weapon' then
        table.insert(weapons, eq_mainhand)
    end

    if eq_offhand ~= nil and eq_offhand.type == 'weapon' then
        table.insert(weapons, eq_offhand)
    end

    local is_dual_wielding = #weapons == 2
    local ac = defense:getArmorValue()

    local combat_info = {
        ac = ac,
        attacks = {},
    }

    for _, weapon in ipairs(weapons) do
        local roll = ndn.dice('1d20').roll()
        local is_crit = roll == 20 -- critical hit, dealing maximum damage
        local is_hit = false

        local attack = offense:getAttackValue(weapon, is_dual_wielding)
        local damage = 0

        if roll > 1 then -- a roll of 1 is a critical miss
            is_hit = is_crit or (roll + attack) > ac
        end

        if is_hit then
            damage = offense:getDamageValue(weapon, is_crit)
            health:harm(damage)
        end

        table.insert(combat_info.attacks, {
            roll    = roll,
            is_hit  = is_hit,
            is_crit = is_crit,
            attack  = attack,
            damage  = damage,
        })

        -- no more attacks possible after target has died
        if not health:isAlive() then break end
    end

    return combat_info
end

return M
