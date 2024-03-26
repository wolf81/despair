--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Health = {}

Health.new = function(entity, def)
    local total = 1

    local hd = def['hd']
    if hd ~= nil then
        total = ndn.dice(hd).average()
    else
        local stats = entity:getComponent(Stats)
        if stats ~= nil then
            -- TODO: should be STR stat + 1d6 per level
            total = stats:getValue('str') + ndn.dice('1d6').roll()
        end
    end

    local current = total

    local getValue = function(self) return current end

    local reduce = function(self, hitpoints) current = mmax(current - hitpoints, 0) end

    local isAlive = function(self) return current > 0 end

    return setmetatable({
        getValue = getValue,
        reduce   = reduce,
        isAlive  = isAlive,
    }, Health)
end

return setmetatable(Health, {
    __call = function(_, ...) return Health.new(...) end,
})
