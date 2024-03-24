local Attack = {}

function Attack.new(entity, target)
    local did_execute = false

    local execute = function(self, level, duration)
        if did_execute then return end

        did_execute = true

        local health = target:getComponent(Health)
        local damage = math.random(15, 25)
        health:remove(damage)

        Signal.emit('attack', entity, target, damage)
    end

    return setmetatable({
        -- methods
        execute = execute,
    }, Attack)
end

return setmetatable(Attack, { 
	__call = function(_, ...) return Attack.new(...) end,
})
