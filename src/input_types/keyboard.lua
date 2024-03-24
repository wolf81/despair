local Keyboard = {}

Keyboard.new = function(entity)
    local getAction = function(self, level)         
        local direction = Direction.NONE
        if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
            direction = Direction.W
        elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            direction = Direction.E
        elseif love.keyboard.isDown('up') or love.keyboard.isDown('w') then
            direction = Direction.N
        elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
            direction = Direction.S
        elseif love.keyboard.isDown('space') then
            -- TODO: clean-up
            return Move(entity, entity.coord)
        end

        local next_coord = entity.coord + direction

        -- ensure entity can move to next coord
        if next_coord == entity.coord then return nil end
        if level:isBlocked(next_coord) then 
            local entities = level:getEntities(next_coord, function(e) return e.type == 'npc' end)
            if #entities > 0 then
                local target = entities[1]
                return Attack(entity, target)
            end

            return nil 
        end 

        level:setBlocked(entity.coord, false)
        level:setBlocked(next_coord, true)
        return Move(entity, next_coord)
    end

    return setmetatable({
        -- methods
        getAction = getAction,
    }, Keyboard)
end

return setmetatable(Keyboard, {
    __call = function(_, ...) return Keyboard.new(...) end,
})