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
    local getAction = function(self, level)
        local player = level:getPlayer()
        if not player then return Idle(level, entity) end

        if player ~= nil then
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
        end

        -- try to move in a random direction
        local direction = getRandomDirection()
        local next_coord = entity.coord + direction

        -- ensure entity can move to next coord
        if level:isBlocked(next_coord) then return Idle(level, entity) end 
        if #level:getEntities(next_coord) > 0 then return Idle(level, entity) end

        return Move(level, entity, next_coord, direction)
    end

    return setmetatable({
        -- methods
        getAction   = getAction,
    }, Cpu)
end

return setmetatable(Cpu, {
    __call = function(_, ...) return Cpu.new(...) end,
})
