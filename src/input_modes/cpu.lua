--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom, mfloor = love.math.random, math.floor

local Cpu = {}

local DIRS = {
    Direction.N, Direction.NW,
    Direction.E, Direction.NE,
    Direction.S, Direction.SW,
    Direction.W, Direction.SE,
}

local function getRandomDirection(level, coord)
    local dirs = lume.shuffle(DIRS)

    for _, dir in ipairs(dirs) do
        local next_coord = coord + dir
        local is_blocked = level:isBlocked(next_coord) or (#level:getEntities(next_coord) > 0) 
        if not is_blocked then return dir end
    end

    return Direction.NONE
end

local function getDirectionToPlayer(level, coord)
    local dir, dist = Direction.NONE, math.huge

    for _, next_dir in ipairs(DIRS) do
        local next_coord = coord + next_dir
        local is_blocked = #level:getEntities(next_coord) > 0
        local next_dist = level:getPlayerDistance(next_coord)
        if not is_blocked and next_dist < dist then
            dist = next_dist
            dir = next_dir
        end
    end    

    return dir
end

local function getMoveCost(entity, direction)
    local move_speed = entity:getComponent(MoveSpeed)
    local ap = move_speed:getValue()

    if Direction.isOrdinal(direction) then
        return mfloor(ap * ORDINAL_MOVE_FACTOR)
    end

    return ap
end

Cpu.new = function(entity)
    local action = nil
    local is_chasing_player = false

    local getAction = function(self, level, ap)
        local player = level:getPlayer()

        local distance = player.coord:dist(entity.coord)
        if distance < 2 then
            local equip = entity:getComponent(Equipment)
            if equip:tryEquipMelee() then
                return Attack(level, entity, player)
            end
        elseif distance < 10 then
            local equip = entity:getComponent(Equipment)
            if equip:tryEquipRanged() then
                -- check line of sight
                if level:inLineOfSight(entity.coord, player.coord) then
                    return Attack(level, entity, player)
                end
            end
        end

        local move_speed = entity:getComponent(MoveSpeed)
        local ap_cost = move_speed:getValue()

        local path, coord = {}, entity.coord
        while ap > 0 do    
            if not is_chasing_player and level:inLineOfSight(coord, player.coord) then
                is_chasing_player = true
            end

            local direction = (is_chasing_player and 
                getDirectionToPlayer(level, coord) or 
                getRandomDirection(level, coord))

            local next_coord = coord + direction

            if not level:isBlocked(next_coord) and #level:getEntities(next_coord) == 0 then
                table.insert(path, next_coord)
                ap = ap - getMoveCost(entity, direction)
                coord = next_coord
            else
                table.insert(path, coord)
                ap = ap - getMoveCost(entity, Direction.NONE)
            end
        end

        -- if a path of coords could be generated, move according to path
        if #path > 0 then return Move(level, entity, unpack(path)) end

        return nil
    end

    return setmetatable({
        -- methods
        getAction   = getAction,
    }, Cpu)
end

return setmetatable(Cpu, {
    __call = function(_, ...) return Cpu.new(...) end,
})
