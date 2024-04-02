--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Attack = {}

Attack.new = function(level, entity, target)
    local did_execute, is_finished = false, false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        local status = CombatResolver.resolve(entity, target)

        Signal.emit('attack', entity, target, status, duration)

        Timer.after(duration, function()
            is_finished = true
        end)
    end

    local getCost = function() return ACTION_BASE_AP_COST end

    local isFinished = function() return is_finished end

    return setmetatable({
        -- methods
        isFinished  = isFinished,
        getCost     = getCost,
        execute     = execute,
    }, Attack)
end

return setmetatable(Attack, { 
	__call = function(_, ...) return Attack.new(...) end,
})
