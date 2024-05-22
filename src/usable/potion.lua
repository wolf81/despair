--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Potion = {}

Potion.new = function(entity, def)
    local use = function(source, target, level, duration)
        if target == nil then return false end

        local health = target:getComponent(Health)
        health:heal(lrandom(2, 6))

        return true
    end
    
    return setmetatable({
        -- methods
        use = use,    
    }, Potion)
end

return setmetatable(Potion, {
    __call = function(_, ...) return Potion.new(...) end,
})
