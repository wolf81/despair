--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Equipment = {}

Equipment.new = function(entity, def)
    local update = function(self, dt) end

    return setmetatable({
        update = update,
    }, Equipment)
end

return setmetatable(Equipment, {
    __call = function(_, ...) return Equipment.new(...) end,
})
