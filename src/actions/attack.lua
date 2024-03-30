--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Attack = {}

Attack.new = function(level, entity, target)
    local did_execute = false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        local status = CombatResolver.resolve(entity, target)

        Signal.emit('attack', entity, target, status, duration)
    end

    local getAP = function() return 30 end

    return setmetatable({
        -- methods
        getAP   = getAP,
        execute = execute,
    }, Attack)
end

return setmetatable(Attack, { 
	__call = function(_, ...) return Attack.new(...) end,
})
