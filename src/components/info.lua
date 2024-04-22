--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Info = {}

local addArmorInfo = function(info, armor)
    table.insert(info, { ['Armor Class'] = tostring(armor.ac) })
end

local addWeaponInfo = function(info, weapon)
    table.insert(info, { ['Attack'] = tostring(weapon.attack) })

    local damage = ndn.dice(weapon.damage)
    local min, max = damage:range()
    table.insert(info, { ['Damage'] = min .. '-' .. max })
end

local getInfo = function(entity)
    local info = {}

    if entity.type == 'armor' then
        addArmorInfo(info, entity)
    end

    if entity.type == 'weapon' then
        addWeaponInfo(info, entity)
    end

    return info
end

local function getDescription(entity)
    local item_info = getInfo(entity)

    local key_len = 0
    local val_len = 0

    -- Determine key_len based on longest key length while appending colon and space, for example:
    -- • given the keys 'Armor Class', 'Damage', 'Name', the key_len would be 11
    -- • but when displaying in a string, we would add colon and space, hence key_len will be 13
    -- • when displayed in string might look as such with right padding based on key_len:
    --     Name:        John
    --     Armor Class: 15
    --     Damage:      1d8+2
    for _, info in ipairs(item_info) do
        for k, v in pairs(info) do
            key_len = math.max(key_len, k:len())
            val_len = math.max(val_len, v:len())
        end
    end

    -- reserve length for 2 characters: `: `
    key_len = key_len + 2 

    local s = ''
    for _, info in ipairs(item_info) do
        for k, v in pairs(info) do
            s = (s .. 
                StringHelper.padRight(k .. ': ', key_len) .. 
                StringHelper.padLeft(v, val_len) .. 
                '\n')
        end
    end

    -- trim newline seperator at end of string
    return lume.trim(s)
end

Info.new = function(entity, def) 
    local name, description = string.upper(entity.name), nil

    local getName = function(self) return name end

    local getDescription = function(self)
        if not description then description = getDescription(entity) end

        return description
    end

    return setmetatable({
        getName         = getName,
        getDescription  = getDescription,
    }, Info)
end

return setmetatable(Info, {
    __call = function(_, ...) return Info.new(...) end,
})
