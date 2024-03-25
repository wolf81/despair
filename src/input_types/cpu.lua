local lrandom = love.math.random

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W }
    return dirs[lrandom(#dirs)]
end

Cpu.new = function(entity)
    local getAction = function(self, level) 
        local next_coord = entity.coord + getRandomDirection()

        -- ensure entity can move to next coord
        if level:isBlocked(next_coord) then return Idle(level, entity) end 
        if #level:getEntities(next_coord) > 0 then Idle(level, entity) end

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
