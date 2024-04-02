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

    local update = function(self, dt, level)
        if not is_enabled then return end

        if action == nil or action:isFinished() then
            local health = entity:getComponent(Health)
            if not health:isAlive() then
                action = Destroy(level, entity)
                action:execute()
                return
            end

            if action == nil or action:isFinished() then
                for _, input_mode in ipairs(input_modes) do
                    action = input_mode:getAction(level)
                    if action then
                        action:execute()
                        break
                    end
                end
            end

        end
    end
    
    local setEnabled = function(self, flag)
        is_enabled = (flag == true)
    end

    return setmetatable({             
        -- methods
        update      = update,
        setEnabled  = setEnabled,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
