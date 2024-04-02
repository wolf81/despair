--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Idle = {}

Idle.new = function(level, entity)
    local did_execute, is_finished = false, false

    local duration = ACTION_BASE_AP_COST / 30 / GAME_SPEED

    local execute = function(self)
        if did_execute then return end

        did_execute = true

        Signal.emit('idle', entity, duration)

        Timer.after(duration, function()
            is_finished = true
        end)
    end

    local isFinished = function() return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        getDuration = getDuration,
        isFinished  = isFinished,
    }, Idle)
end

return setmetatable(Idle, {
    __call = function(_, ...) return Idle.new(...) end,
})
