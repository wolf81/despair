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

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        Signal.emit('move', entity, coord, duration)

        Timer.tween(duration, entity, { coord = coord }, 'linear', function()
            entity.coord = coord
            is_finished = true
        end)
    end

    local getCost = function()
        local move_speed = entity:getComponent(MoveSpeed)
        local cost = ACTION_BASE_AP_COST / move_speed:getValue() * ACTION_BASE_AP_COST

        if Direction.isOrdinal(direction) then
            cost = cost * ORDINAL_COST_FACTOR
        end

        return cost
    end

    local isFinished = function() return is_finished end

    return setmetatable({
        -- methods
        isFinished  = isFinished,
        getCost     = getCost,
        execute     = execute,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
