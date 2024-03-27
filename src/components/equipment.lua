--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Equipment = {}

local SLOTS = { 
    ['mainhand']    = true, 
    ['offhand']     = true, 
    ['chest']       = true,
}

Equipment.new = function(entity, def)
    local equip = {}

    for slot, _ in pairs(SLOTS) do
        equip[slot] = nil
    end

    for _, id in ipairs(def['equip']) do
        local item = EntityFactory.create(id)
        if item.type == 'armor' then
            if item.kind == 'chest' then
                equip.chest = item
            elseif item.kind == 'shield' then
                equip.offhand = item
            end
        elseif item.type == 'weapon' then
            if item.kind == '2h' then
                equip.offhand = nil
                equip.mainhand = item
            elseif item.kind == '1h' or item.kind == 'light' then
                equip.mainhand = item
            elseif item.kind == 'ranged_1h' then
                equip.mainhand = item
            elseif item.kind == 'ranged_2h' then
                equip.offhand = nil
                equip.mainhand = item
            end
        end
    end

    local getItem = function(self, slot)
        assert(SLOTS[slot] ~= nil, 'invalid slot "' .. slot .. '"')
        return equip[slot]
    end

    local equipMelee = function(self) 
        -- TODO: should swap items & return true if melee was equipped
        local weapon_type = equip.mainhand.kind
        return weapon_type ~= 'ranged_1h' and weapon_type ~= 'ranged_2h' 
    end

    local equipRanged = function(self)
        -- TODO: should swap items & return true if ranged was equipped
        local weapon_type = equip.mainhand.kind
        return (weapon_type == 'ranged_1h') or (weapon_type == 'ranged_2h') 
    end

    return setmetatable({
        -- methods
        getItem     = getItem,
        equipMelee  = equipMelee,
        equipRanged = equipRanged,
    }, Equipment)
end

return setmetatable(Equipment, {
    __call = function(_, ...) return Equipment.new(...) end,
})
