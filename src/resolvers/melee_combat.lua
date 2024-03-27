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
    local is_crit = roll == 20
    local is_hit = is_crit or (roll + weapon:getAttack() > armor:getValue())
    local damage = weapon:getDamage(is_crit)

    if is_hit then
        health:reduce(damage)
    end
    
    return damage, is_crit
end

return M
