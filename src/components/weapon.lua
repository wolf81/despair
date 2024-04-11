--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Weapon = {}

Weapon.new = function(entity, def)
    return setmetatable({
        -- properties
        kind        = def.kind,
        attack      = def.attack,
        damage      = def.damage,
        projectile  = def.projectile,
    }, Weapon)
end

return setmetatable(Weapon, {
    __call = function(_, ...) return Weapon.new(...) end,
})
