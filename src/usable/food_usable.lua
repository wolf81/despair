--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local FoodUsable = {}

FoodUsable.new = function(entity, def)    
    local use = function(self, source, target, level, duration)
        if target == nil then return false end

        local energy = target:getComponent(Energy)
        energy:eatFood(5)

        return true
    end

    return setmetatable({
        -- methods 
        use = use,   
    }, FoodUsable)
end

return setmetatable(FoodUsable, {
    __call = function(_, ...) return FoodUsable.new(...) end,
})
