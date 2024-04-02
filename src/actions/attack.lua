--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Attack = {}

Attack.new = function(level, entity, target)
    local did_execute, is_finished = false, false

    local duration = ACTION_BASE_AP_COST / 30 / GAME_SPEED

    local execute = function(self)
        if did_execute then return end

        did_execute = true

        local status = CombatResolver.resolve(entity, target)

        Signal.emit('attack', entity, target, status, duration)

        Timer.after(duration, function()
            is_finished = true
        end)
    end

    local isFinished = function() return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        isFinished  = isFinished,
    }, Attack)
end

return setmetatable(Attack, { 
	__call = function(_, ...) return Attack.new(...) end,
})
