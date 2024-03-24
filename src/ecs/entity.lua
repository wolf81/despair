--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Entity = {}

-- create a new entity based on a definition and a coordinate
function Entity.new(def, coord)
    assert(def ~= nil, 'missing parameter "def"')
    assert(coord ~= nil, 'missing parameter "coord"')
    
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

    -- update entity with delta time and level state
    -- currently an empty implementation as the component system handles updating of components
    local update = function(self, dt, level)
        -- body
    end

    -- draw the entity
    local draw = function(self)
        -- TODO: all entities should have at least a "dummy" Visual component
        self:getComponent(Visual):draw()
    end

    return setmetatable({
        -- properties
        id              = IdGenerator.generate(),
        coord           = coord,
        type            = def.type,
        flags           = 0,
        z_index         = 1,
        -- methods
        getComponent    = getComponent,
        removeComponent = removeComponent,
        addComponent    = addComponent,
        update          = update,
        draw            = draw,
    }, Entity)
end

return setmetatable(Entity, { __call = function(_, ...) return Entity.new(...) end })
