--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

M.use = function(usable, source, target, level, duration)
    if target == nil then return false end

    local energy = target:getComponent(Energy)
    energy:eatFood(5)

    return true
end

return M
