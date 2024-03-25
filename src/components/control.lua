--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Control = {}

Control.new = function(entity, def, input_type)
    assert(input_type ~= nil, 'missing parameter "input_type"')
    
    local update = function(self, dt) end

    local getAction = function(self, level) 
        local health = entity:getComponent(Health)
        if not health:isAlive() then 
            return Destroy(level, entity) 
        end

        return input_type:getAction(level)
    end

    return setmetatable({        
        -- methods
        update      = update,
        getAction   = getAction,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})