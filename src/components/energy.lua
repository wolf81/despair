--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Energy = {}

local MAX_ENERGY = 300

Energy.new = function(entity, def)
    local health = entity:getComponent(Health)
    assert(health ~= nil, 'missing component: "Health"')

    local energy = MAX_ENERGY - 25

    local expend = function(self, amount)
        energy = energy - (amount or 1)

        -- at maximum hunger the entity dies
        if energy < 1 then
            health:harm(health:getValue())
            Signal.emit('energy', entity, entity.name .. ' dies from hunger!')
        end
    end

    local eatFood = function(self, amount)
        assert(amount ~= nil, 'missing argument "amount"')
        energy = energy + amount * 20

        -- when eating too much, the stomach explodes
        if energy > MAX_ENERGY then
            health:harm(health:getValue())
            Signal.emit('energy', entity, entity.name .. ' dies from eating too much food!')
        end
    end

    local getValue = function(self)
        local current = math.min(math.max(energy, 0), MAX_ENERGY) 
        return current, MAX_ENERGY 
    end

    return setmetatable({
        -- methods
        expend      = expend,
        eatFood     = eatFood,
        getValue    = getValue,
    }, Energy)
end

return setmetatable(Energy, {
    __call = function(_, ...) return Energy.new(...) end,
})