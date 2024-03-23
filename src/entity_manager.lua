local EntityManager = {}

local function getKey(coord)
    return coord.x .. ':' .. coord.y
end

function EntityManager.new()
    -- store entity info per coord as such: 
    --  { 
    --      ['5:7'] = { player     }, 
    --      ['1:4'] = { bat, eagle }, 
    --      ...,
    --  } 
    local entity_info = {}

    -- store coord info per entity as such:
    --  {
    --      player  = (5, 7),
    --      bat     = (1, 4),
    --      eagle   = (1, 4),
    --      ...,
    --  }
    local coord_info = {}

    -- add entity to manager
    local addEntity = function(self, new_entity)
        assert(coord_info[new_entity] == nil, 'entity already added to collection')

        -- add to entity info
        local key = getKey(new_entity.coord)
        local entities = entity_info[key] or {}
        table.insert(entities, new_entity)
        entity_info[key] = entities

        -- add to coord info
        coord_info[new_entity] = new_entity.coord
    end

    -- remove entity from manager
    local removeEntity = function(self, old_entity)
        local old_coord = coord_info[old_entity]
        assert(old_coord ~= nil, 'entity is not part of collection')

        -- remove from entity info
        local key = getKey(old_coord)
        local entities = entity_info[key]
        for idx, entity in ipairs(entities) do
            if entity == old_entity then
                table.remove(entities, idx)
                break
            end
        end

        -- remove from coord info
        coord_info[old_entity] = nil
    end

    -- get entities at a given coordinate
    local getEntities = function(self, coord, fn)
        fn = fn or function(entity) return true end

        local entities = entity_info[getKey(coord)] or {}
        local filtered = {}

        for _, entity in ipairs(entities) do
            if fn(entity) then
                table.insert(filtered, entity)
            end
        end

        return filtered
    end

    -- iterate through all entities
    local eachEntity = function(self)
        local entity = nil

        return function()
            entity, _ = next(coord_info, entity)
            return entity
        end
    end

    -- draw all entities
    local draw = function()
        for _, entities in pairs(entity_info) do
            for _, entity in ipairs(entities) do
                entity:draw()
            end
        end
    end

    local moveHandler = function(old_entity, next_coord)
        assert(coord_info[old_entity] ~= nil, 'entity is not part of collection')

        local old_coord = coord_info[old_entity]

        local key = getKey(old_coord)
        local entities = entity_info[key]
        for i, entity in ipairs(entities) do
            if entity == old_entity then 
                table.remove(entities, i) 
                break
            end
        end

        key = getKey(next_coord)
        entities = entity_info[key] or {}
        table.insert(entities, old_entity)
        entity_info[key] = entities

        coord_info[old_entity] = next_coord
    end

    -- TODO: better naming
    local register = function(self)
        Signal.register('move', moveHandler)
    end

    -- TODO: better naming
    local unregister = function(self)
        Signal.unregister('move', moveHandler)
    end

    return setmetatable({
        -- methods
        addEntity       = addEntity,
        removeEntity    = removeEntity,
        getEntities     = getEntities,
        eachEntity      = eachEntity,
        draw            = draw,
        register        = register,
        unregister      = unregister,
    }, EntityManager)
end

return setmetatable(EntityManager, { 
    __call = function(_, ...) return EntityManager.new(...) end,
})
