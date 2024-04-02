--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Control = {}

Control.new = function(entity, def, ...)
    local input_modes = {...}
    assert(#input_modes > 0, 'missing argument(s): "Keyboard", "Mouse" and/or "Cpu"')

    local is_enabled = true
    local action = nil
    local ap = 0

    local update = function(self, dt)
        for _, input_mode in ipairs(input_modes) do
            input_mode:update(dt)
        end
    end
    
    local getAction = function(self, level)
        if not is_enabled then return end 

        if action and not action:isFinished() then return action end

        local health = entity:getComponent(Health)
        if not health:isAlive() then
            action = Destroy(level, entity) 
        else
            for _, input_mode in ipairs(input_modes) do
                action = input_mode:getAction(level)
                if action then break end
            end
        end

        if action then
            ap = ap - action:getCost()
        end

        return action
    end

    local setEnabled = function(self, flag)
        is_enabled = (flag == true)
    end

    local addAP = function(self, value)
        ap = ap + value
    end

    local getAP = function(self)
        return ap
    end

    return setmetatable({             
        -- methods
        addAP       = addAP,
        getAP       = getAP,
        getAction   = getAction,
        setEnabled  = setEnabled,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
