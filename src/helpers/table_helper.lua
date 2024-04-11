--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.readOnly = function(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function(tbl, key, value)
            error("attempt to modify read-only table")
        end,
        __metatable = false,
   })
end

return M
