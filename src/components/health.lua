--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmin, mmax = math.min, math.max

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
        total = ndn.dice(hd).roll()
        current = total
    else
        total = stats:getValue('str') + 1
        current = total
    end

    -- reduce health by amount of hitpoints
    -- returns current & total health
    local harm = function(self, hitpoints) 
        current = mmax(current - hitpoints, 0) 
        return current, total
    end

    -- increase health by amount of hitpoints, up to maximum allowed
    -- returns current & total health
    local heal = function(self, hitpoints)
        current = mmin(current + hitpoints, total)
        return current, total
    end

    -- increase current & total by amount of hitpoints
    -- returns current & total health
    local increase = function(self, hitpoints)
        assert(hitpoints >= 1 and hitpoints <= 6, '"hitpoints" should be a value between 1 and 6')
        total = total + hitpoints 
        current = current + hitpoints
        return current, total
    end

    -- check if hitpoints is greater than 0
    local isAlive = function(self) return current > 0 end

    -- get current & total health value
    local getValue = function(self) return current, total end

    local time = 0
    local update = function(self, dt)
        time = time + dt
        if time > 5.0 and self:isAlive() then
            time = time - 5.0
            self:heal(1)
        end
    end

    return setmetatable({
        update      = update,
        getValue    = getValue,
        isAlive     = isAlive,
        harm        = harm,
        heal        = heal,
    }, Health)
end

return setmetatable(Health, {
    __call = function(_, ...) return Health.new(...) end,
})
