--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

local definitions = {}
local type_info = {}

local function createEntity(def, coord)
    assert(def ~= nil, 'missing argument: "def"')
    assert(coord ~= nil, 'missing argument: "coord"')

    local id = def['id']
    print('create: ' .. id .. ' ' .. tostring(coord))

    local entity = Entity(def, coord) 

    entity.flags = M.getFlags(id, entity.type) 
    -- provice every entity with an Info component, for displaying name and details in UI
    entity:addComponent(Info(entity, def))

    if def.texture ~= nil then entity:addComponent(Visual(entity, def)) end  

    if entity.type == 'pc' then
        entity.z_index = 15
        entity:addComponent(Control(entity, def, Keyboard(entity), Mouse(entity)))
        entity:addComponent(Class(entity, def))
        entity:addComponent(Race(entity, def))
        entity:addComponent(Backpack(entity, def))
        entity:addComponent(Equipment(entity, def))
        entity:addComponent(Skills(entity, def))
        entity:addComponent(Stats(entity, def))
        entity:addComponent(Cartographer(entity, def))
        entity:addComponent(Health(entity, def))
        entity:addComponent(Offense(entity, def))
        entity:addComponent(Defense(entity, def))
        entity:addComponent(MoveSpeed(entity, def))
        entity:addComponent(HealthBar(entity, def))
        entity:addComponent(Energy(entity, def))
        entity:addComponent(PC(entity, def))

        -- equip all from backpack
        entity:getComponent(Backpack):equipAll()
    elseif entity.type == 'npc' then
        entity.z_index = 10        
        entity:addComponent(NPC(entity, def))
        entity:addComponent(Control(entity, def, Cpu(entity)))
        entity:addComponent(Backpack(entity, def))
        entity:addComponent(Equipment(entity, def))
        entity:addComponent(Skills(entity, def))
        entity:addComponent(Health(entity, def))
        entity:addComponent(Offense(entity, def))
        entity:addComponent(Defense(entity, def))
        entity:addComponent(MoveSpeed(entity, def))
        entity:addComponent(HealthBar(entity, def))
        -- TODO: optionally allow some NPCs to have a class as described in Microlite20 manual?

        -- equip all from backpack
        entity:getComponent(Backpack):equipAll()
    elseif entity.type == 'armor' then
        entity.z_index      = 5
        entity.kind         = def['kind']
        entity.ac           = def['ac']

        entity:addComponent(Item(entity, def))
        entity:addComponent(Equippable(entity, def))
    elseif entity.type == 'weapon' then
        entity.z_index      = 5

        -- TODO: remove, use properties inside Weapon component instead
        entity.kind         = def['kind']
        entity.attack       = def['attack']
        entity.damage       = def['damage']
        entity.projectile   = def['projectile']

        entity:addComponent(Item(entity, def))
        entity:addComponent(Equippable(entity, def))
    elseif entity.type == 'ring' then
        entity.z_index = 5

        entity:addComponent(Item(entity, def))
        entity:addComponent(Equippable(entity, def))
    elseif entity.type == 'necklace' then
        entity.z_index = 5

        entity:addComponent(Item(entity, def))
        entity:addComponent(Equippable(entity, def))
    elseif entity.type == 'potion' then
        entity.z_index = 5

        entity:addComponent(Usable(entity, def))
        entity:addComponent(Item(entity, def))
    elseif entity.type == 'tome' then
        entity.z_index = 5

        entity:addComponent(Usable(entity, def))
        entity:addComponent(Item(entity, def))
    elseif entity.type == 'wand' then
        entity.z_index = 5

        entity:addComponent(Usable(entity, def))
        entity:addComponent(Item(entity, def))
    elseif entity.type == 'food' then
        entity.z_index = 5

        entity:addComponent(Usable(entity, def))
        entity:addComponent(Item(entity, def))        
    elseif entity.type == 'effect' then
        entity.z_index = 20
    elseif entity.type == 'spell' then        
        entity.z_index = 20 

        entity:addComponent(Usable(entity, def))
    end

    return entity
end

M.register = function(definition)
    assert(definition.id ~= nil, 'missing field: "id"')
    assert(definition.type ~= nil, 'missing field: "type"')

    definitions[definition.id] = definition
    if type_info[definition.type] == nil then
        type_info[definition.type] = {}
    end

    table.insert(type_info[definition.type], definition.id)
end

M.clear = function()
    definitions = {}
    type_info = {}
    id = 0
end

M.create = function(...)
    local args = {...}

    local arg = args[1]
    assert(arg ~= nil, 'missing argument: "string" or "table"')

    local def = nil

    local arg_type = type(arg)
    if arg_type == 'string' then
        def = definitions[arg]
    elseif arg_type == 'table' then
        def = arg
    else
        error('invalid argument type: "' .. arg_type .. '"')
    end

    local coord = #args > 1 and args[2] or vector(0, 0)

    return createEntity(def, coord)
end

M.getIds = function(type_name)
    return type_info[type_name]
end

M.getDefinition = function(id)
    return definitions[id]
end

M.getFlags = function(id, type)
    local flags = 0

    local def = definitions[id]
    if def ~= nil then return FlagsHelper.parseFlags(def['flags'] or {}, type) end

    return 0
end

return M
