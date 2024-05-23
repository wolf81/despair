--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local PotionUsable = {}

PotionUsable.new = function(entity, def)
    local use = function(self, source, target, level, duration)
        if target == nil then return false end

        local health = target:getComponent(Health)
        health:heal(lrandom(2, 6))

        return true
    end
    
    return setmetatable({
        -- methods
        use = use,    
    }, PotionUsable)
end

return setmetatable(PotionUsable, {
    __call = function(_, ...) return PotionUsable.new(...) end,
})
