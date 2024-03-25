local M = {}

M.resolve = function(entity, target)
    local health = target:getComponent(Health)
    local armor = target:getComponent(Armor)
    local weapon = entity:getComponent(Weapon)
    
    local attack = weapon:getAttack()
    local is_hit = attack >= armor:getValue()
    local damage = 0

    if is_hit then
        damage = weapon:getDamage()        
        health:remove(damage)
    end
    
    return damage
end

return M
