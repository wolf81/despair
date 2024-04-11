--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Defense = {}

local function getAC(entity)
    if not entity then return 0 end

    local armor = entity:getComponent(Armor)
    return armor and armor.ac or 0
end

Defense.new = function(entity, def)
    local equipment = entity:getComponent(Equipment)
    assert(equipment ~= nil, 'missing component: "Equipment"')

    -- set base armor class, used for NPCs
    local base = getAC(entity)

    local getArmorValue = function(self)
        local bonus = 0

        -- add AC for chest armor
        local chest = equipment:getItem('chest')
        bonus = bonus + getAC(chest)

        -- add AC for offhand item, most likely a shield
        local offhand = equipment:getItem('offhand')
        bonus = bonus + getAC(offhand)

        -- add dexterity bonus in case of player characters
        local stats = entity:getComponent(Stats)
        if stats ~= nil then
            bonus = bonus + stats:getBonus('dex')
        end

        return base + bonus
    end

    return setmetatable({
        -- methods
        getArmorValue   = getArmorValue,
    }, Defense)
end

return setmetatable(Defense, {
    __call = function(_, ...) return Defense.new(...) end,
})
