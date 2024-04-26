--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Entity = {}

-- create a new entity based on a definition and a coordinate
Entity.new = function(def, coord)
    assert(def ~= nil, 'missing argument "def"')
    assert(coord ~= nil, 'missing argument "coord"')
    
    local components = {}

    -- add a component by type - if a component for given type is already added, will be replaced
    local addComponent = function(self, component)
        components[getmetatable(component)] = component 
    end

    -- remove a component by type
    local removeComponent = function(self, T)
        components[T] = nil
    end

    -- get a component by type
    local getComponent = function(self, T)
        return components[T]
    end

    -- draw the entity
    local draw = function(self)
        self:getComponent(Visual):draw()
    end

    return setmetatable({
        -- properties
        id              = def.id,                   -- subtype identifier (see type)
        gid             = IdGenerator.generate(),   -- global unique id
        type            = def.type,                 -- type as defined in data file
        name            = def.name or 'unknown',
        flags           = 0,
        coord           = coord:clone(),            -- tile coord
        remove          = false,                    -- set to true to remove from play
        z_index         = 1,                        -- z-index for rendering
        -- methods
        draw            = draw,
        getComponent    = getComponent,
        addComponent    = addComponent,
        removeComponent = removeComponent,
    }, Entity)
end

return setmetatable(Entity, { 
    __call = function(_, ...) return Entity.new(...) end,
})
