--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Keyboard = {}

Keyboard.new = function(entity)
    local was_pressed = {}
    
    local update = function(self, dt, level)
        -- body
    end

    local getAction = function(self, level, ap)
        for key in pairs(was_pressed) do
            if not love.keyboard.isDown(key) then
                if key == 'b' then
                    Signal.emit('drop-item', entity)
                elseif key == '9' then
                    Signal.emit('use-wand', entity)
                end                
            end
        end

        was_pressed = {}

        local direction = Direction.NONE
        if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
            direction = Direction.W
        elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            direction = Direction.E
        elseif love.keyboard.isDown('up') or love.keyboard.isDown('w') then
            direction = Direction.N
        elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
            direction = Direction.S
        elseif love.keyboard.isDown('q') then
            direction = Direction.NW
        elseif love.keyboard.isDown('e') then
            direction = Direction.NE
        elseif love.keyboard.isDown('z') then 
            direction = Direction.SW
        elseif love.keyboard.isDown('c') then
            direction = Direction.SE
        elseif love.keyboard.isDown('b') then
            was_pressed['b'] = true
        elseif love.keyboard.isDown('9') then
            was_pressed['9'] = true
        end

        if direction == Direction.NONE then return nil end

        love.mouse.setVisible(false)

        -- ensure entity can move to next coord
        local next_coord = entity.coord + direction
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

        return Move(level, entity, next_coord)
    end

    return setmetatable({
        -- methods
        getAction   = getAction,
        update      = update,
    }, Keyboard)
end

return setmetatable(Keyboard, {
    __call = function(_, ...) return Keyboard.new(...) end,
})
