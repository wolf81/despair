--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

local definitions = {}
local type_info = {}

local function parseFlags(flags)
    local val = 0

    for idx, flag in ipairs(flags) do
        print('[!] FLAG', idx, flag)
        if flag == 'PR' then
            val = bit.bor(val, 0x1)
        end
    end

    return val
end

M.register = function(dir_path, fn)
    fn = fn or function() end
    
    local filenames = love.filesystem.getDirectoryItems(dir_path)
    local base_path = love.filesystem.getRealDirectory(dir_path)
    for _, filename in ipairs(filenames) do     
        if not string.find(filename, '.*%.lua') then goto continue end

        local filepath = base_path .. '/' .. dir_path .. '/' .. filename
        print('register: ' .. filepath)
        local getContents = assert(loadfile(filepath))
        local definition = getContents()

        assert(definition.id ~= nil, 'id is required')
        definitions[definition.id] = definition

        assert(definition.type ~= nil, 'type is required')
        if type_info[definition.type] == nil then
            type_info[definition.type] = {}
        end
        table.insert(type_info[definition.type], definition.id)

        -- if a function is provided, execute on the prototype, this can be 
        -- useful for preloading data
        fn(definition)

        ::continue::
    end 
end

M.clear = function()
    definitions = {}
    type_info = {}
    id = 0
end

M.create = function(id, coord)
    local def = definitions[id]

    assert(id ~= nil, 'missing argument: "id"')
    
    print('create: ' .. id .. ' ' .. tostring(coord))

    assert(def ~= nil, 'entity not registered \'' .. id .. '\'')

    local entity = Entity(def, coord or vector(0, 0)) 
    -- provice every entity with an Info component, for displaying name and details in UI
    entity:addComponent(Info(entity, def))

    if def.texture ~= nil then
        entity:addComponent(Visual(entity, def))
    end  

    if entity.type == 'pc' then
        entity.z_index = 15
        local class, race = def['class'], def['race']

        assert(CLASSES[class] ~= nil, 'invalid class "' .. class .. '"')
        entity.class = class

        assert(RACES[race] ~= nil, 'invalid race "' .. race .. '"')
        entity.race = race

        entity:addComponent(Control(entity, def, Keyboard(entity), Mouse(entity)))
        entity:addComponent(Backpack(entity, def))
        entity:addComponent(Equipment(entity, def))
        entity:addComponent(Skills(entity, def))
        entity:addComponent(Stats(entity, def))
        entity:addComponent(Cartographer(entity, def))
        entity:addComponent(Health(entity, def))
        entity:addComponent(Offense(entity, def))
        entity:addComponent(Defense(entity, def))
        entity:addComponent(ExpLevel(entity, def))
        entity:addComponent(MoveSpeed(entity, def))
        entity:addComponent(HealthBar(entity, def))
        entity:addComponent(Energy(entity, def))

        -- equip all from backpack
        entity:getComponent(Backpack):equipAll()
    elseif entity.type == 'npc' then
        entity.z_index = 10        
        entity:addComponent(Control(entity, def, Cpu(entity)))
        entity:addComponent(Backpack(entity, def))
        entity:addComponent(Equipment(entity, def))
        entity:addComponent(Skills(entity, def))
        entity:addComponent(Health(entity, def))
        entity:addComponent(Offense(entity, def))
        entity:addComponent(Defense(entity, def))
        entity:addComponent(MoveSpeed(entity, def))
        entity:addComponent(HealthBar(entity, def))

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
        entity.flags = parseFlags(def['flags']) 
    end

    return entity
end

M.getIds = function(type_name)
    return type_info[type_name]
end

M.getDefinition = function(id)
    return definitions[id]
end

return M
