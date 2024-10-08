--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

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

    local each = function(self)
        local key, value = nil, nil

        return function()
            key, value = next(cache, key)
            return key, value
        end
    end

    return setmetatable({
        -- methods
        get         = get,
        each        = each,
        register    = register,
    }, Cache)
end

return setmetatable(Cache, { 
    __call = function(_, ...) return Cache.new(...) end,
})
