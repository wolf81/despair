local Group = {}

local function executeActions(actions, duration, fn)
    local action = table.remove(actions, 1)

    action:execute(duration, function()
        if #actions > 0 then 
            executeActions(actions, duration, fn)
        else
            fn()
        end
    end)
end

Group.new = function(level, entity, actions)
    local did_execute, is_finished = false, false

    local cost = 0
    for _, action in ipairs(actions) do
        cost = cost + action:getCost()
    end

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        local action_duration = duration / #actions

        executeActions(actions, action_duration, function()
            is_finished = true
            if fn then fn() end
        end)
    end

    local getCost = function(self) return cost end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        getCost     = getCost,
        isFinished  = isFinished,
    }, Group)    
end

return setmetatable(Group, {
    __call = function(_, ...) return Group.new(...) end,
})
