--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Defense = {}

Defense.new = function(entity, def)
    local equipment = entity:getComponent(Equipment)
    assert(equipment ~= nil, 'missing component: "Equipment"')

    -- set base armor class, used for NPCs
    local base = def['ac'] or 0

    local getArmorValue = function(self)
        local bonus = 0

        -- add AC for chest armor
        local chest = equipment:getItem('chest')
        if chest ~= nil then
            bonus = bonus + chest.ac
        end

        -- add AC for offhand item, most likely a shield
        local offhand = equipment:getItem('offhand')
        if offhand ~= nil and offhand.type == 'armor' then
            bonus = bonus + offhand.ac
        end

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
