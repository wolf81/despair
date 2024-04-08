--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Move = {}

local ORDINAL_COST_FACTOR = 1.4

Move.new = function(level, entity, coord, direction)
    local did_execute, is_finished = false, false

    level:setBlocked(entity.coord, false)
    level:setBlocked(coord, true)

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        Signal.emit('move', entity, coord, duration)

        Timer.tween(duration, entity, { coord = coord }, 'linear', function()
            entity.coord = coord
            is_finished = true
        end)
    end

    local getCost = function(self) 
        local cost = entity:getComponent(MoveSpeed):getValue()

        if Direction.isOrdinal(direction) then
            cost = mfloor(cost * ORDINAL_COST_FACTOR)
        end

        return cost
    end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        getCost     = getCost,
        isFinished  = isFinished,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
