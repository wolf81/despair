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
    ['head']        = true,
    ['back']        = true, -- cloak
    ['chest']       = true,
    ['hands']       = true,
    ['legs']        = true,
    ['feet']        = true,
    ['neck']        = true, -- necklace
    ['ring1']       = true,
    ['ring2']       = true,
}

Equipment.new = function(entity, def)
    local backpack = entity:getComponent(Backpack)
    assert(backpack ~= nil, 'missing component: "Backpack"')

    local equip = {}

    for slot, _ in pairs(SLOTS) do
        equip[slot] = nil
    end

    local getItem = function(self, slot, fn)
        assert(SLOTS[slot] ~= nil, 'invalid slot "' .. slot .. '"')

        fn = fn or function(item) return true end

        local item = equip[slot]

        return fn(item) and item or nil
    end

    -- equip the first melee item that can be found in backpack
    -- do nothing if a melee item is already equipped
    local tryEquipMelee = function(self) 
        local filter = function(item) 
            return item.type == 'weapon' and item.kind ~= 'ranged_1h' and item.kind ~= 'ranged_2h' 
        end

        -- already equipped
        if equip.mainhand ~= nil and filter(equip.mainhand) then return true end

        -- find item in backpack
        local items = backpack:take(function(item) return filter(item) end)

        if #items > 0 then
            -- equip first item found
            self:equip(items[1])

            -- return all extra items to backpack
            for i = 2, #items do backpack:put(items[i]) end

            -- equipped successfully 
            return true
        end

        -- failed to equip
        return false
    end

    -- equip the first ranged item that can be found in backpack
    -- do nothing if a ranged item is already equipped
    local tryEquipRanged = function(self)
        local filter = function(item) 
            return item.type == 'weapon' and (item.kind == 'ranged_1h' or item.kind == 'ranged_2h') 
        end

        -- already equipped
        if equip.mainhand ~= nil and filter(equip.mainhand) then return true end

        -- find item in backpack
        local items = backpack:take(function(item) return filter(item) end)

        if #items > 0 then
            -- equip first item found
            self:equip(items[1])

            -- return all extra items to backpack
            for i = 2, #items do backpack:put(items[i]) end

            -- equipped successfully 
            return true
        end

        -- failed to equip
        return false
    end

    -- unequip an item from a slot, moving the item to backpack 
    -- will do nothing if slot is empty
    local unequip = function(self, slot)
        assert(SLOTS[slot] ~= nil, 'invalid slot: "' .. slot .. '"')

        -- remote item from slot and put in backpack
        local item = equip[slot]
        equip[slot] = nil
        backpack:put(item)
    end

    -- equip any item in a slot, returns true if successful
    local equip = function(self, item)
        if item == nil then return false end

        if item.type == 'armor' then
            if item.kind == 'chest' then
                self:unequip('chest')
                equip.chest = item
                return true
            elseif item.kind == 'shield' then
                self:unequip('offhand')
                equip.offhand = item
                return true
            end
        elseif item.type == 'weapon' then
            if item.kind == '2h' then
                self:unequip('mainhand')
                self:unequip('offhand')
                equip.mainhand = item
                return true
            elseif item.kind == 'light' then
                if equip.mainhand ~= nil and equip.offhand == nil then
                    print('eq offhand')
                    equip.offhand = item
                else
                    print('eq mainhand')
                    self:unequip('mainhand')
                    equip.mainhand = item                    
                end
                return true
            elseif item.kind == '1h' then
                self:unequip('mainhand')
                equip.mainhand = item                    
                return true
            elseif item.kind == 'ranged_1h' then
                self:unequip('mainhand')
                equip.mainhand = item
                return true
            elseif item.kind == 'ranged_2h' then
                self:unequip('mainhand')
                self:unequip('offhand')
                equip.mainhand = item
                return true
            end
        end

        return false
    end

    -- equip all items from backpack
    local equipAll = function(self)
        for item in backpack:each() do
            self:equip(backpack:take(item.gid))
        end
    end

    return setmetatable({
        -- methods
        tryEquipRanged  = tryEquipRanged,
        tryEquipMelee   = tryEquipMelee,
        equipAll        = equipAll,
        didEquip        = didEquip,
        unequip         = unequip,
        getItem         = getItem,
        equip           = equip,
    }, Equipment)
end

return setmetatable(Equipment, {
    __call = function(_, ...) return Equipment.new(...) end,
})
