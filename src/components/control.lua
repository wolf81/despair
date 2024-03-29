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
    local time_units = 0

    local update = function(self, dt)
        for _, input_mode in ipairs(input_modes) do
            input_mode:update(dt)
        end
    end
    
    local getAction = function(self, level, time_units)
        if not is_enabled then return end 

        -- if time_units is nil, choose any action
        -- otherwise choose action possible by time

        local health = entity:getComponent(Health)
        if not health:isAlive() then 
            return Destroy(level, entity) 
        end

        for _, input_mode in ipairs(input_modes) do
            local action = input_mode:getAction(level)
            if action ~= nil then return action end
        end

        return nil
    end

    local setEnabled = function(self, flag)
        is_enabled = (flag == true)
    end

    local getInitiative = function(self)
        local base = ndn.dice('1d20').roll()
        local bonus = 0

        -- maybe not very efficient to do this every turn
        local stats = entity:getComponent(Stats)
        if stats ~= nil then
            bonus = bonus + stats:getBonus('dex')
        end

        return base + bonus
    end

    return setmetatable({             
        -- methods
        getAction       = getAction,
        getInitiative   = getInitiative,
        setEnabled      = setEnabled,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
