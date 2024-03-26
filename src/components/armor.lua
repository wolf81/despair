--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Armor = {}

Armor.new = function(entity, def)
    local equipment = entity:getComponent(Equipment)
    assert(equipment ~= nil, 'component missing: "Equipment"')

    local base = def['ac'] or 0

    local getValue = function(self)
        local bonus = 0

        local chest = equipment:getItem('chest')
        if chest ~= nil then
            bonus = bonus + chest.ac
        end

        local offhand = equipment:getItem('offhand')
        if offhand ~= nil and offhand.type == 'armor' then
            bonus = bonus + offhand.ac
        end

        local stats = entity:getComponent(Stats)
        if stats ~= nil then
            bonus = bonus + stats:getBonus('dex')
        end

        return base + bonus
    end

    return setmetatable({
        -- methods
        getValue    = getValue,
    }, Armor)
end

return setmetatable(Armor, {
    __call = function(_, ...) return Armor.new(...) end,
})
