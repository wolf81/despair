--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Idle = {}

Idle.new = function(level, entity)
    local did_execute, is_finished = false, false

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        Signal.emit('idle', entity, duration)

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
    }, Idle)
end

return setmetatable(Idle, {
    __call = function(_, ...) return Idle.new(...) end,
})
