--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.padRight = function(str, len, char)
    return string.rep(char or ' ', len - #str) .. str
end

M.padLeft = function(str, len, char)
    return str .. string.rep(char or ' ', len - #str)
end

return M
