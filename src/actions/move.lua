--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Move = {}

local function tween(duration, entity, coords)
    local coord = table.remove(coords, 1)

    local fn = function() entity.coord = coord end

    if #coords > 0 then
        fn = function() tween(duration, entity, coords) end
    end

    return Timer.tween(duration, entity, { coord = coord }, 'linear', fn)
end

Move.new = function(level, entity, coords)
    assert(coords ~= nil, 'missing argument: coords')

    local did_execute = false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        local coord = coords[#coords]

        Signal.emit('move', entity, coord, duration)

        tween(duration / #coords, entity, coords)
    end

    local getAP = function()
        local move_speed = entity:getComponent(MoveSpeed)
        return 30 / move_speed:getValue() * 30
    end

    return setmetatable({
        -- methods
        getAP   = getAP,
        execute = execute,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
