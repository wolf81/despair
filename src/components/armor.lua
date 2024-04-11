--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Armor = {}

Armor.new = function(entity, def)
    return setmetatable({
        -- properties
        ac      = def.ac or 0,
        kind    = def.kind or '',
    }, Armor)
end

return setmetatable(Armor, {
    __call = function(_, ...) return Armor.new(...) end,
})
