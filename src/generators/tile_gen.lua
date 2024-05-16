--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local lrandom = love.math.random

local M = {}

-- TODO: should be weighted
local FLOOR_TILES   = {  22,  23,  24 }
local WALL_TILES_H  = { 342, 343, 344 }
local WALL_TILES_V  = { 322, 323, 324 }

M.generate = function(grid)
    local height, width = #grid, #grid[1]

    local tiles = {}

    for y = 1, height do
        tiles[y] = {}

        for x = 1, width do
            local tile_id = grid[y][x]

            if tile_id == math.huge then
                -- transparent
                tiles[y][x] = 1
            else
                if tile_id == 1 then
                    -- wall (horizontal or vertical)
                    if y < height and grid[y + 1][x] == 1 then
                        tiles[y][x] = WALL_TILES_V[lrandom(#WALL_TILES_V)]
                    else
                        tiles[y][x] = WALL_TILES_H[lrandom(#WALL_TILES_H)]
                    end
                else
                    -- floor
                    tiles[y][x] = FLOOR_TILES[lrandom(#FLOOR_TILES)]
                end
            end
        end
    end

    return tiles
end

return M
