--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Health = {}

Health.new = function(entity, def)
    local hd = def['hd']
    local stats = entity:getComponent(Stats)
    local current, total = 1, 1

    assert(hd ~= nil or stats ~= nil, 'missing field "hd" or component "Stats"')

    local exp_level = entity:getComponent(ExpLevel)
    if exp_level ~= nil then
        assert(exp_level:getValue() ~= 1, 'level should be 1, for additional levels call "increase"')
    end

    if hd ~= nil then
        total = ndn.dice(hd).average()
        current = total
    else
        total = stats:getValue('str') + 1
        current = total
    end

    local drain = function(self, hitpoints) 
        current = mmax(current - hitpoints, 0) 
    end

    local increase = function(self, hitpoints)
        assert(hitpoints >= 1 and hitpoints <= 6, '"hitpoints" should be a value between 1 and 6')
        total = total + hitpoints 
        current = current + hitpoints
    end

    local getCurrent = function(self) return current end

    local getTotal = function(self) return total end

    local isAlive = function(self) return current > 0 end

    return setmetatable({
        getCurrent  = getCurrent,
        getTotal    = getTotal,
        isAlive     = isAlive,
        drain       = drain,
    }, Health)
end

return setmetatable(Health, {
    __call = function(_, ...) return Health.new(...) end,
})
