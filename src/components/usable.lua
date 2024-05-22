--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local lrandom = love.math.random

local Usable = {}

local USABLE_TYPE_INFO = {
    ['potion']  = Potion,
    ['spell']   = Spell,
    ['wand']    = Wand,
    ['food']    = Food,
    ['tome']    = Tome,
}

Usable.new = function(entity, def)
    local amount = 1

    if entity.type == 'wand' or entity.type == 'tome' then
        amount = lrandom(1, 4)
    end

    local T = USABLE_TYPE_INFO[entity.type]
    assert(T ~= nil, 'no usable type defined for "' .. entity.type .. '"')
    local usable = T(entity, def)

    -- the default use function is a noop, just returning success status: false
    local use = function(self, source, target, level, duration) 
        usable:use(source, target, level, duration)
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
        requiresTarget  = requiresTarget,
    }, Usable)
end

return setmetatable(Usable, {
    __call = function(_, ...) return Usable.new(...) end,
})
