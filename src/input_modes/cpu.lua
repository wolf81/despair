--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom = love.math.random

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W, Direction.NW, Direction.SW, Direction.NE, Direction.SE }
    return dirs[lrandom(#dirs)]
end

Cpu.new = function(entity)
    local action = nil

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

        local moves = {}
        while ap > 0 do    
            -- try to move in a random direction
            local direction = getRandomDirection()
            local next_coord = entity.coord + direction

            if not level:isBlocked(next_coord) and #level:getEntities(next_coord) == 0 then
                local move = Move(level, entity, next_coord, direction)
                ap = ap - move:getCost()
                table.insert(moves, move)
            else
                local move = Idle(level, entity)
                ap = ap - move:getCost()
                table.insert(moves, move)
            end
        end

        if #moves == 1 then return moves[1] end

        if #moves > 1 then
            return Group(level, entity, moves)
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
