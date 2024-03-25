local lrandom = love.math.random

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W }
    return dirs[lrandom(#dirs)]
end

Cpu.new = function(entity)
    local getAction = function(self, level) 
        local direction = getRandomDirection()

        local next_coord = entity.coord + direction

        -- ensure entity can move to next coord
        if next_coord == entity.coord then return nil end
        if level:isBlocked(next_coord) then return nil end 
        if #level:getEntities(next_coord) > 0 then return nil end

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