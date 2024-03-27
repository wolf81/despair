--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Control = {}

Control.new = function(entity, def, input_mode)
    assert(input_mode ~= nil, 'missing parameter "input_mode"')

    local is_enabled = true
    
    local getAction = function(self, level)
        if not is_enabled then return end 

        local health = entity:getComponent(Health)
        if not health:isAlive() then 
            return Destroy(level, entity) 
        end

        return input_mode:getAction(level)
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
