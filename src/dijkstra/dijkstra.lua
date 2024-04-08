--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local PriorityQueue = require 'src.dijkstra.pqueue'

-- not a number: indicates in a Dijkstra map that a tile is not reachable
local nan = 0/0

local mmin, mhuge = math.min, math.huge

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

-- generate a string key based on x & y value
local function getKey(x, y) 
    return bit.lshift(y, 16) + x
end

Dijkstra.new = function(map, sx, sy, blocked, incl_diagonal)
    local getNeighbors = incl_diagonal and getNeighborsCO or getNeighborsC
    local map_h, map_w = #map, #map[1]
    local d_map = {}

    local update = function(self, x, y)
        d_map = {}
        local start = { x = x, y = y }

        for y = 1, map_h do
            d_map[y] = {}
            for x = 1, map_w do
                d_map[y][x] = mhuge
            end
        end

        local unvisited = PriorityQueue()

        -- create an empty Dijkstra map, all tile distances are set to math.huge
        -- or nan if unreachable
        for y = 1, map_h do
            for x = 1, map_w do
                if blocked(x, y) then
                    d_map[y][x] = nan
                else
                    d_map[y][x] = mhuge
                    unvisited:enqueue(getKey(x, y), mhuge)
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
            local x = bit.band(key, 0xFF)
            local y = bit.rshift(key, 16)

            -- process each neighbor for current x and y value
            for _, neighbor in ipairs(getNeighbors(x, y)) do
                local n_x, n_y = unpack(neighbor)
                local n_key = getKey(n_x, n_y)

                -- if the neighbor tile was visited previously, skip
                if not unvisited:contains(n_key) then goto continue end

                -- calculate distance and update the unvisited neighbor tile
                local n_dist = mmin(d_map[n_y][n_x], dist + 1)
                unvisited:update(n_key, n_dist)

                ::continue::
            end

            -- since x and y position is now visited, remove from unvisited list
            unvisited:remove(key)

            -- update distance in Dijkstra map for the visited tile
            d_map[y][x] = dist
        end
    end

    update(nil, sx, sy)

    local getDistance = function(self, x, y)
        if (y < 1) or (y > map_h - 1) or (x < 1) or (x > map_w - 1) then 
            return mhuge 
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
