--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mceil, mmax = math.ceil, math.max

local M = {}

local FLOOR_TILES   = {  22,  25,  26,  23,  24,  27 }
local WALL_TILES_H  = { 342, 343, 344, 345, 346, 347 }
local WALL_TILES_V  = { 322, 323, 324, 325, 326, 327 }

local function getWeighted(values)
    local weighted = {}
    local weight = 150
    for idx, value in ipairs(values) do
        weighted[value] = weight
        weight = mmax(mceil(weight / 3), 1)
    end
    return weighted
end

M.generate = function(grid)
    local height, width = #grid, #grid[1]

    local tiles = {}

    local wall_tiles_v = getWeighted(WALL_TILES_V)
    local wall_tiles_h = getWeighted(WALL_TILES_H)
    local floor_tiles = getWeighted(FLOOR_TILES)

    for y = 1, height do
        tiles[y] = {}

        for x = 1, width do
            local tile_id = grid[y][x]

            if tile_id == math.huge then
                -- transparent
                tiles[y][x] = 1
            else
                if tile_id == 1 then
                    if y < height and grid[y + 1][x] == 1 then
                        tiles[y][x] = lume.weightedchoice(wall_tiles_v)
                    else
                        tiles[y][x] = lume.weightedchoice(wall_tiles_h)
                    end
                else
                    tiles[y][x] = lume.weightedchoice(floor_tiles)
                end
            end
        end
    end

    return tiles
end

return M
