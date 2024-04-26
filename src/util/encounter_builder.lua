--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin, mmax, lrandom = math.min, math.max, love.math.random

local EncounterBuilder = {}

local function newRandomNPC(types, coord)
    local type = types[lrandom(#types)]
    return EntityFactory.create(type, coord)
end

EncounterBuilder.new = function(level_info, x_range, y_range)
    local makeEncounter = function(self, level, coord)
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

        local npc = newRandomNPC(level_info.npcs, coords[lrandom(#coords)])
        level:addEntity(npc)
    end
    
    return setmetatable({
        -- methods
        makeEncounter = makeEncounter,
    },EncounterBuilder)
end

return setmetatable(  EncounterBuilder, {
    __call = function(_, ...) return  EncounterBuilder.new(...) end,
})
