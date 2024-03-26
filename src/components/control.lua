--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Control = {}

Control.new = function(entity, def, input_type)
    assert(input_type ~= nil, 'missing parameter "input_type"')

    local is_enabled = true
    
    local getAction = function(self, level)
        if not is_enabled then return end 

        local health = entity:getComponent(Health)
        if not health:isAlive() then 
            return Destroy(level, entity) 
        end

        return input_type:getAction(level)
    end

    local setEnabled = function(self, flag)
        is_enabled = (flag == true)
    end

    return setmetatable({             
        -- methods
        getAction   = getAction,
        setEnabled  = setEnabled,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
