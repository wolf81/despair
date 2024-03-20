--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.generate = function(size)
    local tiles = {}

    local map_w = math.pow(2, size) + 1
    local map_h = map_w

    for y = 1, map_h do
        tiles[y] = {}
        for x = 1, map_w do
            tiles[y][x] = 0

            if y == 1 or y == map_h or x == 1 or x == map_w then
                tiles[y][x] = 1
            end
        end
    end

    return tiles
end

return M
