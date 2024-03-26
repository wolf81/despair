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

    local is_hit = roll + weapon:getAttack() >= armor:getValue()
    local damage = 0

    if is_hit then
        damage = weapon:getDamage()        
        health:reduce(damage)
    end
    
    return damage
end

return M
