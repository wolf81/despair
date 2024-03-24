local Attack = {}

function Attack.new()
    local did_execute = false

    local execute = function(self, level, duration)
        if did_execute then return end

        did_execute = true

        -- Timer.tween(duration, entity, { coord = coord }, 'linear', function() 
        --     entity.coord = coord
        -- end)
    end

    return setmetatable({
        -- methods
        execute = execute,
    }, Attack)
end

return setmetatable(Attack, { 
	__call = function(_, ...) return Attack.new(...) end,
})
