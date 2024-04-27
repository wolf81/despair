--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

M.padRight = function(str, len, char)
    return string.rep(char or ' ', len - #str) .. str
end

M.padLeft = function(str, len, char)
    return str .. string.rep(char or ' ', len - #str)
end

M.capitalize = function(str)
    return str:gsub("^%l", string.upper)
end

M.endsWith = function(str, suffix) 
    return str:match((suffix or '') .. '$') 
end

M.concat = function(tbl, join)
    join = join or ''

    local str = ''
    for idx, val in ipairs(tbl) do
        str = str .. val

        if idx < #tbl then
            str = str .. join
        end
    end

    return str
end

return M
