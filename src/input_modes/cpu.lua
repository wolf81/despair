--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom, mfloor = love.math.random, math.floor

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W, Direction.NW, Direction.SW, Direction.NE, Direction.SE }
    return dirs[lrandom(#dirs)]
end

local function getDirectionToPlayer(level, coord)
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W, Direction.NW, Direction.SW, Direction.NE, Direction.SE }
    local next_dir = Direction.NONE

    local dist = math.huge
    for _, dir in ipairs(dirs) do
        local next_coord = coord + dir
        local next_dist = level:getDistToPlayer(next_coord)
        if next_dist < dist then
            dist = next_dist
            next_dir = dir
        end
    end    

    return next_dir
end

Cpu.new = function(entity)
    local action = nil
    local is_chasing_player = false

    local getAction = function(self, level, ap)
        local player = level:getPlayer()

        local distance = player.coord:dist(entity.coord)
        if distance < 2 then
            local equip = entity:getComponent(Equipment)
            if equip:equipMelee() then
                return Attack(level, entity, player)
            end
        elseif distance < 10 then
            local equip = entity:getComponent(Equipment)
            if equip:equipRanged() then
                -- check line of sight
                if level:inLineOfSight(entity.coord, player.coord) then
                    return Attack(level, entity, player)
                end
            end
        end

        local move_speed = entity:getComponent(MoveSpeed)
        local ap_cost = move_speed:getValue()

        local coord = entity.coord
        local coords = {}
        while ap > 0 do    
            if level:inLineOfSight(coord, player.coord) then
                is_chasing_player = true
            end

            local direction = getRandomDirection()
            if is_chasing_player then
                direction = getDirectionToPlayer(level, coord)
            end

            local next_coord = coord + direction

            if not level:isBlocked(next_coord) and #level:getEntities(next_coord) == 0 then
                table.insert(coords, next_coord)
                coord = next_coord

                if Direction.isOrdinal(direction) then
                    ap = ap - mfloor(ap_cost * 1.4)
                else
                    ap = ap - ap_cost
                end
            else
                table.insert(coords, coord)
                ap = ap - ap_cost
            end
        end

        if #coords > 0 then
            return Move(level, entity, unpack(coords))
        end

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
