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

    local sleep_turns = 0

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
                if sleep_turns > 0 then
                    action = Rest(level, entity)
                    sleep_turns = sleep_turns - 1
                else
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
        end

        return action
    end

    -- toggle enabled state - if disabled will not respond to input from CPU, keyboard, mouse, ...
    local setEnabled = function(self, flag) print('set_enabled', flag);  is_enabled = (flag == true) end

    -- add action points
    local addAP = function(self, value) ap = ap + value end

    -- get current action points
    local getAP = function(self) return ap end

    local setAction = function(self, action_) action = action_ end

    local sleep = function(self, turns) 
        sleep_turns = turns 
    
        local current, total = entity:getComponent(Health):getValue()
        -- TODO: determine recovery rate, recover health every n turns
        -- recovery rate is the modulus value to recover some health (e.g.: 1)

        -- example 1:
        --   lets say a player has 8 current health of 10 total, 2 missing
        --   sleep duration should be normalized to e.g. 48 turns (SLEEP_DURATION)
        --   so, recover health at turns 24 & 48
        --   recovery turns: 48 / 2 = 24 (if sleep_turns % 24 == 0 then addHealth(1))
        --     recovery {
        --       rate  = 1,
        --       turns = 24,
        --     }
        --
        -- example 2:
        --   player: 27 of 40 (13 missing)
        --   recovery turns: 48 / 13 = 3.69 (approx. 4)
        --     recovery {
        --       rate  = 1,
        --       turns = 4,
        --     }
        -- can we improve handling the rounding error (?)
        -- 
        -- example 3:
        --   player: 5 of 8 (3 missing)
        --   recovery turns: 48 / 3 = 16
        --     recovery {
        --       rate  = 1,
        --       turns = 16,
        --     }
    end

    local isSleeping = function(self, turns) return sleep_turns > 0 end

    local awake = function(self) sleep_turns = 0 end

    return setmetatable({             
        -- methods
        isSleeping  = isSleeping,
        setEnabled  = setEnabled,
        setAction   = setAction,
        getAction   = getAction,
        update      = update,
        addAP       = addAP,
        getAP       = getAP,
        sleep       = sleep,
        awake       = awake,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
