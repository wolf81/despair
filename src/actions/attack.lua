--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Attack = {}

function Attack.new(level, entity, target)
    local did_execute = false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        local health = target:getComponent(Health)
        local damage = math.random(15, 25)
        health:remove(damage)
        print('is alive?', health:isAlive())

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
