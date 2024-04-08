--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Attack = {}

Attack.new = function(level, entity, target)
    local did_execute, is_finished = false, false

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        local status = CombatResolver.resolve(entity, target)

        Signal.emit('attack', entity, target, status, duration)

        Timer.after(duration, function()
            is_finished = true
            
            if fn then fn() end
        end)
    end

    local getCost = function(self) return 30 end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        getCost     = getCost,
        isFinished  = isFinished,
    }, Attack)
end

return setmetatable(Attack, { 
	__call = function(_, ...) return Attack.new(...) end,
})
