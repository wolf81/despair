--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Map = {}

function Map.new(tiles, fn)
    fn = fn or function(id) return false end

    local blocked = {}

    for y = 1, #tiles do
        blocked[y] = {}
        for x = 1, #tiles do
            blocked[y][x] = fn(tiles[y][x]) == true
        end
    end

    local setBlocked = function(self, x, y, flag) 
        blocked[y][x] = (flag == true)
    end

    local isBlocked = function(self, x, y)
        return blocked[y][x]
    end

    local size = function(self)
        local w, h = #tiles[1], #tiles
        return w, h
    end

    return setmetatable({
        -- methods
        setBlocked  = setBlocked,
        isBlocked   = isBlocked,
        size        = size,
    }, Map)
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
