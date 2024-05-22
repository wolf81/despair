--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Food = {}

Food.new = function(entity, def)    
    local use = function(source, target, level, duration)
        if target == nil then return false end

        local energy = target:getComponent(Energy)
        energy:eatFood(5)

        return true
    end

    return setmetatable({
        -- methods 
        use = use,   
    }, Food)
end

return setmetatable(Food, {
    __call = function(_, ...) return Food.new(...) end,
})
