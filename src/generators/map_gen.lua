--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

-- recursive backtracker algorithm based on: 
-- https://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking

local bband, bbnot, bbor, lrandom = bit.band, bit.bnot, bit.bor, love.math.random

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

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = lrandom(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function carvePassage(cx, cy, grid)
    local dirs = shuffle({ Dir.N, Dir.S, Dir.E, Dir.W })
    
    for _, dir in ipairs(dirs) do
        local nx, ny = cx + Dx[dir], cy + Dy[dir]
        if ny > 0 and ny <= #grid and nx > 0 and nx <= #grid[ny] and grid[ny][nx] == 0 then
            grid[cy][cx] = bbor(grid[cy][cx], dir)
            grid[ny][nx] = bbor(grid[ny][nx], Opposite[dir])
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
    scale = math.max(scale or 1, 1)

    -- create a maze using recursive backtracker algorithm
    local grid = newGrid(size)
    carvePassage(1, 1, grid)

    -- remove some dead-ends
    -- TODO: seems a little bit buggy, e.g. when removing all dead-ends would expect map to be empty
    for y = 1, #grid do
        for x = 1, #grid[y] do
            local v = grid[y][x]

            if v == Dir.E or v == Dir.W or v == Dir.S or v == Dir.N then
                if lrandom() > 0.5 then
                    local nx, ny = x + Dx[v], y + Dy[v]
                    local nv = grid[ny][nx]
                    grid[ny][nx] = bband(bbnot(Opposite[v]), nv)
                    grid[y][x] = 0
                end
            end
        end
    end

    -- factor takes into account border around map
    local factor = scale + 1

    -- create tiles array and set initial borders
    local tiles = newGrid(size * factor + 1, function(x, y) return math.huge end)

    -- configure tiles in tiles array, based on grid
    for y = 1, size do
        for x = 1, size do
            local v = grid[y][x]

            if v ~= 0 then
                local y1, y2 = (y - 1) * factor + 1, y * factor + 1
                local x1, x2 = (x - 1) * factor + 1, x * factor + 1

                -- add ground tiles
                for ny = y1, y2 do
                    for nx = x1, x2 do
                        if tiles[ny][nx] == math.huge then
                            tiles[ny][nx] = 0
                        end
                    end
                end
                
                -- north blocked: add wall tiles
                if bband(v, Dir.N) == 0 then
                    for nx = x1, x2 do
                        tiles[y1][nx] = 1 
                    end
                end

                -- south blocked: add wall tiles
                if bband(v, Dir.S) == 0 then
                    for nx = x1, x2 do
                        tiles[y2][nx] = 1 
                    end
                end

                -- east blocked: add wall tiles
                if bband(v, Dir.E) == 0 then
                    for ny = y1, y2 do
                        tiles[ny][x2] = 1 
                    end
                end

                -- west blocked: add wall tiles
                if bband(v, Dir.W) == 0 then
                    for ny = y1, y2 do
                        tiles[ny][x1] = 1 
                    end
                end
            end
        end
    end

    return tiles
end

return M
