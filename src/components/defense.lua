--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Defense = {}

Defense.new = function(entity, def)
    local equipment = entity:getComponent(Equipment)
    assert(equipment ~= nil, 'missing component: "Equipment"')

    local base = 0

    local getArmorValue = function(self)
        local npc = entity:getComponent(NPC)
        if npc then return npc:getArmorClass() end

        local ac = 0

        -- add AC for chest armor
        local chest = equipment:getItem('chest')
        if chest ~= nil then
            ac = ac + chest.ac
        end

        -- add AC for offhand item, most likely a shield
        local offhand = equipment:getItem('offhand')
        if offhand ~= nil and offhand.type == 'armor' then
            ac = ac + offhand.ac
        end

        return ac + self:getArmorBonus()
    end

    local getArmorBonus = function(self)
        local bonus = 0

        -- add dexterity bonus in case of player characters
        local stats = entity:getComponent(Stats)
        if stats ~= nil then
            bonus = bonus + stats:getBonus('dex')
        end

        -- get armor class modifiers from e.g. spells
        local modifiers = entity:getComponent(Conditions):get('ac')
        for key, value in pairs(modifiers) do
            bonus = bonus + value
        end

        return bonus
    end

    return setmetatable({
        -- methods
        getArmorValue   = getArmorValue,
        getArmorBonus   = getArmorBonus,
    }, Defense)
end

return setmetatable(Defense, {
    __call = function(_, ...) return Defense.new(...) end,
})
