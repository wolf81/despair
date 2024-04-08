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

    local ap = -1

    local update = function(self, dt, level)
        -- body
    end

    local getAction = function(self, level)
        if not is_enabled then return false end

        if action == nil or action:isFinished() then
            local health = entity:getComponent(Health)
            if not health:isAlive() then
                action = Destroy(level, entity)
            else
                if ap < 0 then return nil end

                for _, input_mode in ipairs(input_modes) do
                    action = input_mode:getAction(level, ap)                
                    if action then
                        ap = ap - action:getCost()
                        break 
                    end
                end
            end
        end

        return action
    end
    
    local setEnabled = function(self, flag)
        is_enabled = (flag == true)
    end

    local addAP = function(self, value)
        ap = ap + value
    end

    local getAP = function(self) return ap end

    return setmetatable({             
        -- methods
        update      = update,
        setEnabled  = setEnabled,
        getAction   = getAction,
        addAP       = addAP,
        getAP       = getAP,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
