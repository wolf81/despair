--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local lrandom, mfloor = love.math.random, math.floor

local Cpu = {}

local DIRS = {
    Direction.N, Direction.NW,
    Direction.E, Direction.NE,
    Direction.S, Direction.SW,
    Direction.W, Direction.SE,
}

local function isBlocked(level, coord)
    if level:isBlocked(coord) or level:hasStairs(coord) then return true end

    local entities = level:getEntities(coord)
    for _, entity in ipairs(entities) do
        if entity:getComponent(Control) then return true end
    end

    return false
end

local function getRandomDirection(level, coord)
    local dirs = lume.shuffle(DIRS)

    for _, dir in ipairs(dirs) do
        if not isBlocked(level, coord + dir) then return dir end
    end

    return Direction.NONE
end

local function getDirectionToPlayer(level, coord)
    local dir, dist = Direction.NONE, math.huge

    for _, next_dir in ipairs(DIRS) do
        local next_coord = coord + next_dir
        local next_dist = level:getPlayerDistance(next_coord)
        if not isBlocked(level, next_coord) and next_dist < dist then
            dist = next_dist
            dir = next_dir
        end
    end    

    return dir
end

Cpu.new = function(entity)
    local in_combat = false

    local update = function(self, dt, level)
        -- body
    end

    local getAction = function(self, level, ap)
        local player = level:getPlayer()

        local distance = mfloor(player.coord:dist(entity.coord))
        if distance > 1 and distance < 8 then
            local equip = entity:getComponent(Equipment)
            if equip:tryEquipRanged() then
                if level:inLineOfSight(entity.coord, player.coord) then
                    return Attack(level, entity, player)
                end
            end
        elseif distance == 1 then
            local equip = entity:getComponent(Equipment)
            if equip:tryEquipMelee() then
                return Attack(level, entity, player)
            end            
        end

        -- a path is a list of coords; also keep track of current coord
        local path, coord = {}, entity.coord
        while ap > 0 do
            local distance = mfloor(coord:dist(player.coord))

            -- start chase player when player enters line of sight
            if not in_combat and distance < 10 then
                in_combat = level:inLineOfSight(coord, player.coord)
            end

            local direction = Direction.NONE

            -- if not standing next to player, either move randomly or towards player if chasing
            if distance > 1 and in_combat then 
                direction = getDirectionToPlayer(level, coord) 
            else
                direction = getRandomDirection(level, coord)
            end 

            -- add next coord to path if not blocked, otherwise add current coord to path
            local next_coord = coord + direction
            if not isBlocked(level, next_coord) then
                table.insert(path, next_coord)
                ap = ap - ActionHelper.getMoveCost(entity, next_coord)
                coord = next_coord
            else
                ap = ap - ActionHelper.getMoveCost(entity, coord)
            end
        end

        -- if a path of coords could be generated, move according to path
        if #path > 0 then return Move(level, entity, unpack(path)) end

        return nil
    end

    local inCombat = function(self) return in_combat end

    return setmetatable({
        -- methods
        getAction   = getAction,
        inCombat    = inCombat,
        update      = update,
    }, Cpu)
end

return setmetatable(Cpu, {
    __call = function(_, ...) return Cpu.new(...) end,
})
