--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom = love.math.random

local Usable = {}

local usePotion = function(self, target)
    if target == nil then return false end

    local health = target:getComponent(Health)
    health:heal(lrandom(2, 6))

    return true, 0
end

local useFood = function(self, target)
    if target == nil then return false end

    local energy = target:getComponent(Energy)
    energy:eatFood(lrandom(2, 5))

    return true, 0
end

Usable.new = function(entity, def)
    -- the generic use function does nothing, just returning
    -- success: false, remaining charges: 1
    local use = function(self, target) return false, 1 end
    
    if entity.type == 'food' then
        use = useFood
    elseif entity.type == 'potion' then
        use = usePotion
    end
    
    return setmetatable({
        use = use,
    }, Usable)
end

return setmetatable(Usable, {
    __call = function(_, ...) return Usable.new(...) end,
})
