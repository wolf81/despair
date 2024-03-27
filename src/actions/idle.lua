--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Idle = {}

Idle.new = function(level, entity)
    local did_execute = false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        Signal.emit('idle', entity, duration)
    end

    return setmetatable({
        -- methods
        execute = execute,
    }, Idle)
end

return setmetatable(Idle, {
    __call = function(_, ...) return Idle.new(...) end,
})
