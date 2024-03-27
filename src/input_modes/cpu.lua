local lrandom = love.math.random

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W }
    return dirs[lrandom(#dirs)]
end

local function getAdjacentPlayer(level, entity)
    for _, dir in ipairs({ Direction.N, Direction.E, Direction.S, Direction.W }) do
        local entities = level:getEntities(entity.coord + dir)
        if #entities > 0 then
            target = entities[1]
            if target.type == 'pc' then
                return target
            end
        end
    end

    return nil
end

Cpu.new = function(entity)
    local getAction = function(self, level)
        local player = getAdjacentPlayer(level, entity)
        if player ~= nil then
            return Attack(level, entity, player)
        end

        -- try to move in a random direction
        local next_coord = entity.coord + getRandomDirection()

        -- ensure entity can move to next coord
        if level:isBlocked(next_coord) then return Idle(level, entity) end 
        if #level:getEntities(next_coord) > 0 then return Idle(level, entity) end

        return Move(level, entity, next_coord)
    end

    return setmetatable({
        -- methods
        getAction = getAction,
    }, Cpu)
end

return setmetatable(Cpu, {
    __call = function(_, ...) return Cpu.new(...) end,
})
