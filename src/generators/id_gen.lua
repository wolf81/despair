--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

local id = 0

-- generate a new id
M.generate = function()
    id = id + 1
    return id
end

return M
