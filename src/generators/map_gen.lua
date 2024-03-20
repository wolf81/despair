--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

local Dir = {
    N = 0x1,
    S = 0x2,
    E = 0x4,
    W = 0x8,
}

local Dx = { [Dir.E] = 1, [Dir.W] = -1, [Dir.S] = 0, [Dir.N] = 0 }
local Dy = { [Dir.E] = 0, [Dir.W] = 0, [Dir.N] = -1, [Dir.S] = 1 }
local Opposite = { [Dir.E] = Dir.W, [Dir.W] = Dir.E, [Dir.S] = Dir.N, [Dir.N] = Dir.S }

local function carvePassage(cx, cy, grid)
    local dirs = lume.shuffle({ Dir.N, Dir.S, Dir.E, Dir.W })
    
    for _, dir in ipairs(dirs) do
        local nx, ny = cx + Dx[dir], cy + Dy[dir]
        if ny > 0 and ny <= #grid and nx > 0 and nx <= #grid[ny] and grid[ny][nx] == 0 then
            grid[cy][cx] = bit.bor(grid[cy][cx], dir)
            grid[ny][nx] = bit.bor(grid[ny][nx], Opposite[dir])
            carvePassage(nx, ny, grid)
        end 
    end
end

local function newGrid(size, fn)
    fn = fn or function(x, y) return 0 end

    local grid = {}
    for y = 1, size do
        grid[y] = {}
        for x = 1, size do
            grid[y][x] = fn(x, y)
        end
    end
    return grid
end

M.generate = function(size)
    local map_w = size + 2
    local map_h = size + 2

    local grid = newGrid(size)
    carvePassage(1, 1, grid)

    local tiles = newGrid(size * 2 + 1, function(x, y) 
        return (y % 2 == 1 or x % 2 == 1) and 1 or 0
    end)

    for y = 1, size do
        for x = 1, size do
            local v = grid[y][x]

            if bit.band(v, Dir.E) ~= 0 then
                tiles[y * 2][x * 2 + 1] = 0
            end 

            if bit.band(v, Dir.S) ~= 0 then
                tiles[y * 2 + 1][x * 2] = 0
            end
        end
    end

    return tiles
end

return M
