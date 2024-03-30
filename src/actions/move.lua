--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Move = {}

Move.new = function(level, entity, coord)
    local did_execute = false

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        Signal.emit('move', entity, coord, duration)

        Timer.tween(duration, entity, { coord = coord }, 'linear', function()
            entity.coord = coord
            fn()
        end)
    end

    local getCost = function()
        local move_speed = entity:getComponent(MoveSpeed)
        return 30 / move_speed:getValue() * 30
    end

    return setmetatable({
        -- methods
        getCost = getCost,
        execute = execute,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
