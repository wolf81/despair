--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Move = {}

local ORDINAL_COST_FACTOR = 1.4

Move.new = function(level, entity, coord, direction)
    local did_execute, is_finished = false, false

    local move_speed = entity:getComponent(MoveSpeed)
    local duration = move_speed:getValue() / GAME_SPEED

    if Direction.isOrdinal(direction) then
        duration = duration * ORDINAL_COST_FACTOR
    end

    local execute = function(self)
        if did_execute then return end

        did_execute = true

        Signal.emit('move', entity, coord, duration)

        Timer.tween(duration, entity, { coord = coord }, 'linear', function()
            entity.coord = coord
            is_finished = true
        end)
    end

    local isFinished = function() return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        isFinished  = isFinished,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
