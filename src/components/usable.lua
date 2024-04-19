--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom = love.math.random

local Usable = {}

local usePotion = function(self, target, level)
    if target == nil then return false end

    local health = target:getComponent(Health)
    health:heal(lrandom(2, 6))

    return true
end

local useFood = function(self, target, level)
    if target == nil then return false end

    local energy = target:getComponent(Energy)
    energy:eatFood(lrandom(2, 5))

    return true
end

local useTome = function(self, target, level)
    print('use tome')
    return false
end

local useWand = function(self, target, level)
    print('use wand')

    local entities = level:getEntities(target, function(entity) 
        -- TODO: some wands might target walls or maybe empty space
        return entity.type == 'pc' or entity.type == 'npc'
    end)

    for _, entity in ipairs(entities) do
        local health = entity:getComponent(Health)
        local damage = ndn.dice('2d4').roll()
        health:harm(damage)
    end

    return false
end

Usable.new = function(entity, def)
    local amount = 1

    -- the generic use function does nothing, just returning
    -- success: false
    local use = function(self, target, level) return false end
    
    if entity.type == 'potion' then
        use = usePotion
    elseif entity.type == 'food' then
        use = useFood
    elseif entity.type == 'wand' then
        use = useWand
        amount = lrandom(1, 4)
    elseif entity.type == 'tome' then
        use = useTome
        amount = lrandom(1, 4)
    end

    -- local getEffect = function(self)
    --     if not def.effect then return end
        
    --     return EntityFactory.create(def.effect)
    -- end

    local getAmount = function(self) return amount end

    local expend = function(self) 
        amount = math.max(amount - 1, 0)
        
        if amount == 0 then Signal.emit('expend', entity.gid) end
    end
    
    return setmetatable({
        getAmount   = getAmount,
        -- getEffect   = getEffect,
        expend      = expend,
        use         = use,
    }, Usable)
end

return setmetatable(Usable, {
    __call = function(_, ...) return Usable.new(...) end,
})
