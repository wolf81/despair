--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

M.getLevel = function(entity)
    local component = entity:getComponent(Class) or entity:getComponent(NPC)
    return component and component:getLevel()
end

return M
