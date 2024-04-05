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

    local base = def['ac'] or 0

    local getArmorValue = function(self)
        local bonus = 0

        local chest = equipment:getItem('chest')
        if chest ~= nil then
            bonus = bonus + chest.ac
        end

        -- add shield bonus, if equipped
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
