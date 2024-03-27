local Mouse = {}

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
            local entities = level:getEntities(next_coord, function(e) return e.type == 'npc' end)
            if #entities > 0 then
                local target = entities[1]
                local health = target:getComponent(Health)
                if health:isAlive() then
                    return Attack(level, entity, target)
                end
            end

            return nil
        end 

        if not Direction.isOrdinal(direction) then
            -- TODO: should allow movement when a diagonal direction is set
            return Move(level, entity, next_coord)
        end

        return nil
    end

    return setmetatable({
        -- methods
        getAction   = getAction,
    }, Mouse)
end

return setmetatable(Mouse, {
    __call = function(_, ...) return Mouse.new(...) end,
})
