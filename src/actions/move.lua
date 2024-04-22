--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Move = {}

Move.new = function(level, entity, ...)
    local did_execute, is_finished = false, false

    local coords = {...}
    assert(#coords > 0, 'missing variable arguments for coords')

    local coord = coords[#coords]

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        Signal.emit('move', entity, coord, duration)

        Timer.tween(duration, entity, { coord = coord }, 'linear', function()
            entity.coord = coord

            is_finished = true
        end)
    end

    local getAP = function(self) return ActionHelper.getMoveCost(entity, unpack(coords)) end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        getAP       = getAP,
        execute     = execute,
        isFinished  = isFinished,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
