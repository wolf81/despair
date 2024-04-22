--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Rest = {}

Rest.new = function(level, entity)
    local did_execute, is_finished = false, false

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        Timer.after(duration, function()
            is_finished = true

            if fn then fn() end
        end)
    end

    local getAP = function(self) return ActionHelper.getIdleCost(entity) end

    local isFinished = function(self) return is_finished end

    return setmetatable({    
        -- methods
        getAP       = getAP,
        execute     = execute,
        isFinished  = isFinished,
    }, Rest)
end

return setmetatable(Rest, {
    __call = function(_, ...) return Rest.new(...) end,
})
