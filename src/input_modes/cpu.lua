local lrandom = love.math.random

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W }
    return dirs[lrandom(#dirs)]
end

Cpu.new = function(entity)
    local getAction = function(self, level)
        local player = level:getPlayer()
        if player ~= nil then
            local distance = player.coord:dist(entity.coord)
            if distance < 2 then
                local equip = entity:getComponent(Equipment)
                if equip:equipMelee() then
                    print('equipped melee')
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
        local next_coord = entity.coord + getRandomDirection()

        -- ensure entity can move to next coord
        if level:isBlocked(next_coord) then return Idle(level, entity) end 
        if #level:getEntities(next_coord) > 0 then return Idle(level, entity) end

        return Move(level, entity, next_coord)
    end

    return setmetatable({
        -- methods
        getAction   = getAction,
    }, Cpu)
end

return setmetatable(Cpu, {
    __call = function(_, ...) return Cpu.new(...) end,
})
