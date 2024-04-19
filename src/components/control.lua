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

    -- whether to respond to input from any of the input modes
    local is_enabled = true

    -- the current action to perform
    local action = nil

    -- the current amount of action points - an action can be performed when AP > 0
    -- only the Destroy action doesn't have an AP requirement
    local ap = 0

    -- update implementation is empty, but required for any component
    local update = function(self, dt, level) 
        for _, input_mode in ipairs(input_modes) do
            input_mode:update(dt, level)
        end
    end

    -- get current action - will try to generate a new action if current action is finished
    local getAction = function(self, level)
        if not is_enabled then return false end

        if action == nil or action:isFinished() then
            local health = entity:getComponent(Health)
            -- if a played has died, will always return Destroy, regardless of current AP
            if not health:isAlive() then
                action = Destroy(level, entity)
                ap = ap - action:getAP()                
            elseif ap > 0 then
                -- find the first action from the input modes list
                for _, input_mode in ipairs(input_modes) do
                    action = input_mode:getAction(level, ap)                
                    if action then 
                        ap = ap - action:getAP()
                        break 
                    end
                end
            end

        end

        return action
    end

    -- toggle enabled state - if disabled will not respond to input from CPU, keyboard, mouse, ...
    local setEnabled = function(self, flag) is_enabled = (flag == true) end

    -- add action points
    local addAP = function(self, value) ap = ap + value end

    -- get current action points
    local getAP = function(self) return ap end

    local setAction = function(self, action_)
        assert(action == nil, 'action already defined')

        action = action_
    end

    return setmetatable({             
        -- methods
        setEnabled  = setEnabled,
        setAction   = setAction,
        getAction   = getAction,
        update      = update,
        addAP       = addAP,
        getAP       = getAP,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
