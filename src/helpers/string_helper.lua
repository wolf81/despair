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

M.getHeight = function(str)
    local lines = select(2, string.gsub(str, '\n', '\n'))

    if lines > 1 then
        return lines * FONT:getHeight() * FONT:getLineHeight() + FONT:getHeight()
    end

    return FONT:getHeight()
end

return M
