--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local lrandom = love.math.random

local Usable = {}

local TYPE_INVOKE_INFO = {
    ['potion']  = Potion.use,
    ['spell']   = Spell.use,
    ['wand']    = Wand.use,
    ['food']    = Food.use,
    ['tome']    = Tome.use,
}

Usable.new = function(entity, def)
    local amount = 1

    if entity.type == 'wand' or entity.type == 'tome' then
        amount = lrandom(1, 4)
    end

    local useFn = TYPE_INVOKE_INFO[entity.type]
    assert(useFn ~= nil, 'no use function defined for "' .. entity.type .. '"')

    -- the default use function is a noop, just returning success status: false
    local use = function(self, source, target, level, duration) 
        useFn(self, source, target, level, duration)
    end
    
    local getEffect = function(self)
        if not def.effect then return nil end
        
        return EntityFactory.create(def.effect)
    end

    local expend = function(self) 
        amount = math.max(amount - 1, 0)
        
        -- TODO: should be deplete
        if amount == 0 then Signal.emit('depleted', entity.gid) end
    end

    local requiresTarget = function(self) 
        return entity.type == 'wand' or entity.type == 'spell'
    end

    return setmetatable({
        -- methods
        use             = use,
        expend          = expend,
        getEffect       = getEffect,
        requiresTarget  = requiresTarget,
    }, Usable)
end

return setmetatable(Usable, {
    __call = function(_, ...) return Usable.new(...) end,
})
