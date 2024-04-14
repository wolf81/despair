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

    local did_eq_weapon_oh = (eq_offhand ~= nil) and eq_offhand.type == 'weapon'
    local did_eq_weapon_mh = (eq_mainhand ~= nil) and eq_mainhand.type == 'weapon'
    local is_dual_wielding = did_eq_weapon_mh and did_eq_weapon_oh

    local roll = ndn.dice('1d20').roll()
    local is_crit = roll == 20 -- critical hit, dealing maximum damage
    local is_miss = roll == 1 -- critical miss

    local attack = offense:getAttackValue(eq_mainhand)
    if is_dual_wielding then 
        attack = attack - 2 
    end

    local ac = defense:getArmorValue()
    local is_hit = (is_crit == true)
    if not (is_miss and is_crit) then
        is_hit = (roll + attack) > ac
    end
    local damage = is_hit and offense:getDamageValue(is_crit) or 0

    if is_hit then
        health:harm(damage)
    end
   
    return {
        ac      = ac,
        roll    = roll,
        attack  = attack,
        damage  = damage,
        is_hit  = is_hit,
        is_crit = is_crit,
        proj_id = eq_mainhand.projectile,
    }
end

return M
