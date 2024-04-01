--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Destroy = {}

Destroy.new = function(level, entity)
    local did_execute, is_finished = false, false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        Signal.emit('destroy', entity, duration)

        local visual = entity:getComponent(Visual)
        visual:fadeOut(duration)

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
    }, Destroy)
end

return setmetatable(Destroy, {
    __call = function(_, ...) return Destroy.new(...) end,
})
