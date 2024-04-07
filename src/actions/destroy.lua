--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Destroy = {}

Destroy.new = function(level, entity)
    local did_execute, is_finished = false, false

    level:setBlocked(entity.coord, false)

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        Signal.emit('destroy', entity, duration)

        Timer.after(duration, function()
            is_finished = true
        end)
    end

    local isFinished = function() return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        isFinished  = isFinished,
    }, Destroy)
end

return setmetatable(Destroy, {
    __call = function(_, ...) return Destroy.new(...) end,
})
