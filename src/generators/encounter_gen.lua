--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin, mmax, lrandom = math.min, math.max, love.math.random

local M = {}

local function newRandomNPC(coord)
    local types = EntityFactory.getIds('npc')
    local type = types[lrandom(#types)]
    return EntityFactory.create(type, coord)
end

-- generate an encounter for a level, based on coord and range from coord
M.generate = function(level, coord, x_range, y_range)
    local level_w, level_h = level:getSize()
    local x1, x2 = mmax(coord.x - x_range, 1), mmin(coord.x + x_range, level_w)
    local y1, y2 = mmax(coord.y - y_range, 1), mmin(coord.y + y_range, level_h)

    local coords = {}
    for x = x1, x2 do
        local next_coord = vector(x, y1)
        if not level:isBlocked(next_coord) and level:inLineOfSight(coord, next_coord) then
            table.insert(coords, next_coord)
        end

        next_coord = vector(x, y2)
        if not level:isBlocked(next_coord) and level:inLineOfSight(coord, next_coord) then
            table.insert(coords, next_coord)
        end
    end

    for y = y1 + 1, y2 - 1 do
        local next_coord = vector(x1, y)
        if not level:isBlocked(next_coord) and level:inLineOfSight(coord, next_coord) then
            table.insert(coords, next_coord)
        end

        next_coord = vector(x2, y)
        if not level:isBlocked(next_coord) and level:inLineOfSight(coord, next_coord) then
            table.insert(coords, next_coord)
        end
    end

    local coord = coords[lrandom(#coords)]
    return newRandomNPC(coord)
end

return M
