--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.resolve = function(entity, target)
    local health = target:getComponent(Health)
    local armor = target:getComponent(Armor)
    local weapon = entity:getComponent(Weapon)

    local roll = ndn.dice('1d20').roll()
    local is_crit = roll == 20 -- critical hit, dealing maximum damage
    local is_miss = roll == 1 -- critical miss
    local attack = weapon:getAttack()
    local ac = armor:getValue()
    local is_hit = is_crit
    if not is_miss then
        is_hit = is_crit or ((roll + attack) > ac)
    end
    local damage = weapon:getDamage(is_crit)

    if is_hit then
        health:drain(damage)
    end
    
    return {
        ac      = ac,
        roll    = roll,
        attack  = attack,
        damage  = damage,
        is_hit  = is_hit,
        is_crit = is_crit,
    }
end

return M
