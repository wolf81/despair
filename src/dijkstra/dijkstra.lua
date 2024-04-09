--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local PriorityQueue = require 'src.dijkstra.pqueue'

local mmin, bband, blshift, brshift = math.min, bit.band, bit.lshift, bit.rshift

local Dijkstra = {}

-- get both cardinal and ordinal neighbors
local function getNeighborsCO(x, y)
    return { 
        { x - 1, y },
        { x + 1, y },
        { x, y - 1 },
        { x, y + 1 },
        { x - 1, y + 1 },
        { x - 1, y - 1 },
        { x + 1, y + 1 },
        { x + 1, y - 1 },
    }
end

-- get cardinal neighbors
local function getNeighborsC(x, y)
    return { 
        { x - 1, y },
        { x + 1, y },
        { x, y - 1 },
        { x, y + 1 },
    }
end

-- generate a key based on x & y value
-- PLEASE NOTE: x and y values should be in range 1 .. 2^16
local function getKey(x, y) return blshift(y, 16) + x end

local function newMap(w, h, value)
    local map = {}
    for y = 1, h do
        map[y] = {}
        for x = 1, w do
            map[y][x] = value
        end
    end
    return map
end

-- create a new Dijkstra map, optionally allow for diagonal movement with diagonal cost
Dijkstra.new = function(map, blocked, incl_diagonal, diagonal_cost)
    local getNeighbors = incl_diagonal and getNeighborsCO or getNeighborsC
    local map_h, map_w = #map, #map[1]
    local incl_diagonal = (incl_diagonal == true)
    local diagonal_cost = diagonal_cost or 1

    -- dijkstra map will be stored here after update is called
    local d_map = nil

    local update = function(self, x, y)
        local start = { x = x, y = y }

        -- create an empty Dijkstra map, with all tile distances set to math.huge
        d_map = newMap(map_w, map_h, math.huge)

        -- add reachable tile coords to the unvisited queue
        local unvisited = PriorityQueue()
        for y = 1, map_h do
            for x = 1, map_w do
                d_map[y][x] = math.huge

                if not blocked(x, y) then
                    unvisited:enqueue(getKey(x, y), math.huge)
                end
            end
        end

        -- set the start position by setting the tile distance value to 0
        d_map[start.y][start.x] = 0
        unvisited:update(getKey(start.x, start.y), 0)

        -- process all unvisited tiles
        while not unvisited:empty() do
            local key, dist = unvisited:dequeue()

            -- decode x and y value from the key
            local x, y = bband(key, 0xFF), brshift(key, 16)

            -- process each neighbor for current x and y value
            for idx, neighbor in ipairs(getNeighbors(x, y)) do
                local n_x, n_y = unpack(neighbor)
                local n_key = getKey(n_x, n_y)

                -- only process tiles not visited previously
                if unvisited:contains(n_key) then 
                    -- calculate and update the distance of unvisited neighbor tile
                    local n_dist = mmin(d_map[n_y][n_x], dist + (idx > 4 and diagonal_cost or 1))
                    unvisited:update(n_key, n_dist)
                end
            end

            -- since x and y position is now visited, remove from unvisited list
            unvisited:remove(key)

            -- update distance in Dijkstra map for the visited tile
            d_map[y][x] = dist
        end
    end

    -- get the distance value for a given coord
    -- will return math.huge is coord is unreachable
    local getDistance = function(self, x, y)
        if (y < 1) or (y > map_h - 1) or (x < 1) or (x > map_w - 1) then 
            return math.huge 
        end

        return d_map[y][x]
    end

    return setmetatable({
        -- methods
        update      = update,
        getDistance = getDistance,
    }, Dijkstra)
end

return setmetatable(Dijkstra, {
    __call = function(_, ...) return Dijkstra.new(...) end,
})
