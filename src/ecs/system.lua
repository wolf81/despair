--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local System = {}

System.new = function(T)
    local components = {}

    local addComponent = function(self, entity)
        local component = entity:getComponent(T)
        if component ~= nil then
            components[entity] = component            
        end
    end

    local removeComponent = function(self, entity)
        components[entity] = nil
    end

    local update = function(self, dt, ...)
        for entity, component in pairs(components) do
            component:update(dt, ...)
        end
    end

    return setmetatable({
        -- methods
        addComponent    = addComponent,
        removeComponent = removeComponent,
        update          = update,
    }, System)
end

return setmetatable(System, { 
    __call = function(_, ...) return System.new(...) end, 
})
