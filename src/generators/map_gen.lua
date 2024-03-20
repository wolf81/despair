--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.generate = function(size)
    local tiles = {}

    for y = 1, size do
        tiles[y] = {}
        for x = 1, size do
            tiles[y][x] = 0

            if y == 1 or y == SIZE or x == 1 or x == SIZE then
                tiles[y][x] = 1
            end
        end
    end

    return tiles
end

return M
