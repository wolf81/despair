--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmax = math.max

local Equipment = {}

local SLOTS = TableHelper.readOnly({ 
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
})

local function isChestArmor(item)
    return (item.type == 'armor' and (
        item.kind == 'light' or 
        item.kind == 'medium' or 
        item.kind == 'heavy' or 
        item.kind == 'none'))
end 

Equipment.new = function(entity, def)
    local backpack = entity:getComponent(Backpack)
    assert(backpack ~= nil, 'missing component: "Backpack"')

    local equip = {}

    for slot, _ in pairs(SLOTS) do
        equip[slot] = nil
    end

    local getItem = function(self, slot, fn)
        if slot == nil then return nil end
        
        assert(SLOTS[slot] ~= nil, 'invalid slot "' .. slot .. '"')

        fn = fn or function(item) return true end

        local item = equip[slot]

        return fn(item) and item or nil
    end

    local getWeapons = function(self)
        local mh_item, oh_item = self:getItem('mainhand'), self:getItem('offhand')

        local weapons = {}
        if mh_item and mh_item.type == 'weapon' then table.insert(weapons, mh_item) end
        if oh_item and oh_item.type == 'weapon' then table.insert(weapons, oh_item) end

        return weapons
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

            -- TODO: if a light weapon was equipped, 
            -- check if we can equip another light weapon?

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

        local class = entity:getComponent(Class)
        if class and not class:canEquip(item) then 
            Signal.emit('notify', 'Your class can not equip this item.')
            return false 
        end

        if item.type == 'armor' then
            if isChestArmor(item) then
                self:unequip('chest')
                equip.chest = item
                return true
            elseif item.kind == 'shield' then
                -- can't carry 2h weapon with shield, so unquip if needed
                if equip.mainhand ~= nil and equip.mainhand.kind == '2h' then
                    self:unequip('mainhand')
                end
                self:unequip('offhand')
                equip.offhand = item
                return true
            end
        elseif item.type == 'weapon' then
            -- TODO: unequip natural weapon (if equipped)

            if item.kind == '2h' then
                self:unequip('mainhand')
                self:unequip('offhand')
                equip.mainhand = item
                return true
            elseif item.kind == 'light' then
                -- can't carry 2h weapon or ranged weapon with offhand weapon, so unquip if needed
                if equip.mainhand ~= nil and (
                    equip.mainhand.kind == '2h' or 
                    equip.mainhand.kind == 'ranged_1h' or 
                    equip.mainhand.kind == 'ranged_2h') then
                    self:unequip('mainhand')
                end

                if equip.offhand ~= nil and equip.offhand.kind == 'shield' then
                    self:unequip('offhand')
                end

                if equip.mainhand ~= nil and equip.offhand == nil and class:canDualWield() then
                    equip.offhand = item
                else
                    self:unequip('mainhand')
                    equip.mainhand = item
                end
                return true
            elseif item.kind == '1h' then
                self:unequip('mainhand')
                equip.mainhand = item                    
                return true
            elseif item.kind == 'ranged_1h' then
                -- don't allow sling to be equipped with offhand weapon, but shield is fine
                if equip.offhand ~= nil and equip.offhand.type == 'weapon' then
                    self:unequip('offhand')
                end

                self:unequip('mainhand')
                equip.mainhand = item
                return true
            elseif item.kind == 'ranged_2h' then
                self:unequip('mainhand')
                self:unequip('offhand')
                equip.mainhand = item
                return true
            end

            -- TODO: if no mainhand weapon equipped, equip natural weapon
        elseif item.type == 'necklace' then
            self:unequip('neck')
            equip.neck = item
            return true
        elseif item.type == 'ring' then
            if equip.ring1 ~= nil and equip.ring2 == nil then
                equip.ring2 = item
            else
                self:unequip('ring1')
                equip.ring1 = item                
            end
            return true
        end

        return false
    end

    return setmetatable({
        -- methods
        equip           = equip,
        unequip         = unequip,
        getItem         = getItem,
        didEquip        = didEquip,
        getWeapons      = getWeapons,
        tryEquipMelee   = tryEquipMelee,
        tryEquipRanged  = tryEquipRanged,
    }, Equipment)
end

return setmetatable(Equipment, {
    __call = function(_, ...) return Equipment.new(...) end,
})
