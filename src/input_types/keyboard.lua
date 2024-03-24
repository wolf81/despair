local Keyboard = {}

Keyboard.new = function(entity)
    local getInput = function(self, level) 
        local direction = Direction.NONE
        if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
            direction = Direction.W
        elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            direction = Direction.E
        elseif love.keyboard.isDown('up') or love.keyboard.isDown('w') then
            direction = Direction.N
        elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
            direction = Direction.S
        end

        local next_coord = entity.coord + direction

        -- ensure entity can move to next coord
        if next_coord == entity.coord then return nil end
        if level:isBlocked(next_coord) then return nil end 
        if #level:getEntities(next_coord) > 0 then return nil end

        return direction
    end

    return setmetatable({
        -- methods
        getInput = getInput,
    }, Keyboard)
end

return setmetatable(Keyboard, {
    __call = function(_, ...) return Keyboard.new(...) end,
})