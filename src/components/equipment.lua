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

    return setmetatable({
        -- methods
        getItem = getItem,
    }, Equipment)
end

return setmetatable(Equipment, {
    __call = function(_, ...) return Equipment.new(...) end,
})
