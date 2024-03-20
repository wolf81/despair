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

M.generate = function(size, scale)
    scale = math.max(scale or 1, 0)

    -- create a maze using recursive backtracker algorithm
    local grid = newGrid(size)
    carvePassage(1, 1, grid)


    -- TODO: dead-end removal
    -- go through each grid tile
    -- if tile has only a single exit, it's a dead-end
    -- use percentage change to remove
    for y = 1, #grid do
        for x = 1, #grid[y] do
            local v = grid[y][x]

            if v == Dir.E or v == Dir.W or v == Dir.S or v == Dir.N then
                local remove = math.random(2) == 1                
                if remove then
                    local nx, ny = x + Dx[v], y + Dy[v]
                    local nv = grid[ny][nx]
                    grid[ny][nx] = bit.band(bit.bnot(Opposite[v]), nv)
                    grid[y][x] = 0
                end
            end
        end
    end

    -- factor takes into account border around map
    local factor = scale + 2

    -- create tiles array and set initial borders
    local tiles = newGrid(size * factor + 1, function(x, y) 
        return (y % factor == 1 or x % factor == 1) and 1 or 0
    end)

    -- TODO: remove some dead-ends

    for y = 1, size do
        for x = 1, size do
            local v = grid[y][x]

            if bit.band(v, Dir.E) ~= 0 then
                for i = 0, scale do
                    tiles[y * factor - i][x * factor + 1] = 0                    
                end
            end 

            if bit.band(v, Dir.S) ~= 0 then
                for i = 0, scale do
                    tiles[y * factor + 1][x * factor - i] = 0
                end
            end

            -- if v == 0 then
            --     for i = 0, scale do
            --         for j = 0, scale do
            --             tiles[y * factor - i][x * factor - j] = nil                    
            --         end                             
            --     end
            -- end
        end
    end

    return tiles
end

return M
