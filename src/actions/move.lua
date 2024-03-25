--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Move = {}

Move.new = function(level, entity, coord)
    local did_execute = false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        level:setBlocked(entity.coord, false)
        level:setBlocked(coord, true)

        Signal.emit('move', entity, coord, duration)

        Timer.tween(duration, entity, { coord = coord }, 'linear', function() 
            entity.coord = coord
        end)
    end

    return setmetatable({
        -- methods
        execute = execute,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
