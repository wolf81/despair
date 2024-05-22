--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

M.use = function(usable, source, target, level, duration)
    if target == nil then return false end

    local health = target:getComponent(Health)
    health:heal(lrandom(2, 6))

    return true
end

return M
