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

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        Signal.emit('destroy', entity, duration)

        Timer.after(duration, function()
            is_finished = true
            
            if fn then fn() end
        end)
    end

    local getCost = function(self) return 0 end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        getCost     = getCost,
        isFinished  = isFinished,
    }, Destroy)
end

return setmetatable(Destroy, {
    __call = function(_, ...) return Destroy.new(...) end,
})
