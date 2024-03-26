--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

local definitions = {}
local type_info = {}

M.register = function(dir_path, fn)
    fn = fn or function() end
    
    local filenames = love.filesystem.getDirectoryItems(dir_path)
    local base_path = love.filesystem.getRealDirectory(dir_path)
    for _, filename in ipairs(filenames) do     
        if not string.find(filename, '.*%.lua') then goto next end

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

        ::next::
    end 
end

M.clear = function()
    definitions = {}
    type_info = {}
    id = 0
end

M.create = function(id, coord)
    local def = definitions[id]

    print('create: ' .. id .. ' ' .. tostring(coord))

    assert(def ~= nil, 'entity not registered \'' .. id .. '\'')

    local entity = Entity(def, coord or vector(0, 0)) 

    if def.texture ~= nil then
        entity:addComponent(Visual(entity, def))
    end  

    if entity.type == 'pc' then
        entity.z_index = 10
        entity:addComponent(Control(entity, def, Keyboard(entity)))
        entity:addComponent(Equipment(entity, def))
        entity:addComponent(Stats(entity, def))
        entity:addComponent(Health(entity, def))
        entity:addComponent(Armor(entity, def))
        entity:addComponent(Weapon(entity, def))
    elseif entity.type == 'npc' then
        entity.z_index = 5
        entity:addComponent(Control(entity, def, Cpu(entity)))
        entity:addComponent(Equipment(entity, def))
        entity:addComponent(Health(entity, def))
        entity:addComponent(Armor(entity, def))
        entity:addComponent(Weapon(entity, def))
    end

    return entity
end

M.getIds = function(type_name)
    return type_info[type_name]
end

return M
