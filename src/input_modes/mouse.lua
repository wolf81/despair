local Mouse = {}

local function tryGetEnemy(level, coord)
    local entities = level:getEntities(coord, function(e) return e.type == 'npc' end)
    if #entities > 0 then
        local target = entities[1]
        local health = target:getComponent(Health)
        if health:isAlive() then
            return target
        end
    end

    return nil
end

Mouse.new = function(entity)
    local getAction = function(self, level)
        if not love.mouse.isDown(1) then return end

        local dxy = Pointer.getCoord() - entity.coord
        local direction = Direction.fromHeading(dxy.x, dxy.y)
        local next_coord = entity.coord + direction

        if direction == Direction.NONE then
            return Idle(level, entity)
        end

        if level:isBlocked(next_coord) then
            local target = tryGetEnemy(level, next_coord)
            if target ~= nil then
                return Attack(level, entity, target)
            end

            return nil
        end 

        return Move(level, entity, next_coord)
    end

    return setmetatable({
        -- methods
        getAction = getAction,
    }, Mouse)
end

return setmetatable(Mouse, {
    __call = function(_, ...) return Mouse.new(...) end,
})
