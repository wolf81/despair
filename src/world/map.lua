--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Map = {}

function Map.new(tiles, fn)
    fn = fn or function(id) return false end

    local height, width = #tiles, #tiles[1]
    local blocked = {}

    for y = 1, height do
        blocked[y] = {}
        for x = 1, width do
            blocked[y][x] = fn(tiles[y][x]) == true
        end
    end

    local setBlocked = function(self, x, y, flag) 
        blocked[y][x] = (flag == true)
    end

    local isBlocked = function(self, x, y)
        return blocked[y][x]
    end

    local getSize = function(self)
        return width, height
    end

    return setmetatable({
        -- methods
        setBlocked  = setBlocked,
        isBlocked   = isBlocked,
        getSize     = getSize,
    }, Map)
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
