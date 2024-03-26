--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Cache = {}

Cache.new = function()
    local cache = {}

    local register = function(self, key, value)
        assert(type(key) == 'string', 'a key must by of string type')
        cache[key] = value
    end

    local get = function(self, key)
        return cache[key]
    end

    return setmetatable({
        -- methods
        register    = register,
        get         = get,
    }, Cache)
end

return setmetatable(Cache, { 
    __call = function(_, ...) return Cache.new(...) end,
})
