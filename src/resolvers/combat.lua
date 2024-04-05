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

    local roll = ndn.dice('1d20').roll()
    local is_crit = roll == 20 -- critical hit, dealing maximum damage
    local is_miss = roll == 1 -- critical miss
    local attack = offense:getAttackValue()
    local ac = defense:getArmorValue()
    local is_hit = (is_crit == true)
    if not (is_miss and is_crit) then
        is_hit = (roll + attack) > ac
    end
    local damage = is_hit and offense:getDamageValue(is_crit) or 0

    if is_hit then
        health:harm(damage)
    end

    local eq_weapon = equipment:getItem('mainhand')
   
    return {
        ac      = ac,
        roll    = roll,
        attack  = attack,
        damage  = damage,
        is_hit  = is_hit,
        is_crit = is_crit,
        proj_id = eq_weapon.projectile,
    }
end

return M
