--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Info = {}

local addArmorInfo = function(details, armor)
    table.insert(info, { ['Armor Class'] = armor.ac })
end

local addWeaponInfo = function(details, weapon)
    table.insert(info, { ['Attack'] = weapon.attack })

    local damage = ndn.dice(weapon.damage)
    table.insert(info, { ['Damage'] = damage.min() .. '-' damage.max() })
end

local getInfo = function(entity)
    local info = {}

    local armor = entity:getComponent(Armor)
    if armor then addArmorInfo(info, armor) end

    local weapon = entity:getComponent(Weapon)
    if weapon then addWeaponInfo(info, weapon) end

    return info
end

Info.new = function(entity, def) 
    local name, info = string.upper(entity.name), nil

    local getName = function(self) return name end

    local getInfo = function(self)
        if not info then info = getInfo(entity) end

        return info
    end

    return setmetatable({
        getName = getName,
        getInfo = getInfo,
    }, Info)
end

return setmetatable(Info, {
    __call = function(_, ...) return Info.new(...) end,
})
