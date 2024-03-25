--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Health = {}

Health.new = function(entity, def)
    local total = 20
    local current = total

    local update = function(self, dt) end

    local getValue = function(self) return current end

    local remove = function(self, value) current = mmax(current - value, 0) end

    local isAlive = function(self) return current > 0 end

    return setmetatable({
        getValue = getValue,
        remove   = remove,
        isAlive  = isAlive,
    }, Health)
end

return setmetatable(Health, {
    __call = function(_, ...) return Health.new(...) end,
})