--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

M.getExtension = function(path) return path:match("^.+(%..+)$")  end

M.getFilename = function(path) return path:match('^(.*)%.') end

return M
