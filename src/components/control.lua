--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Control = {}

local SLEEP_TURNS = 48 -- represents 4.800 actual turns, but compressed by factor 100

Control.new = function(entity, def, ...)
    local input_modes = {...}
    assert(#input_modes > 0, 'missing argument(s): "Keyboard", "Mouse" and/or "Cpu"')

    -- whether to respond to input from any of the input modes
    local is_enabled = true

    local sleep_turns, recovery = 0, {}

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

                    local gain = recovery[sleep_turns]
                    if gain > 0 then health:heal(gain) end

                    -- sleeping expends a bit of energy every couple of turns
                    if sleep_turns % 3 == 0 then entity:getComponent(Energy):expend(1) end                                    

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
    local setEnabled = function(self, flag) is_enabled = (flag == true) end

    -- add action points
    local addAP = function(self, ap_) ap = ap + ap_ end

    -- get current action points
    local getAP = function(self) return ap end

    local setAction = function(self, action_) action = action_ end

    -- forces the related entity to return Rest actions for a certain amount of turns
    -- sleep will be interrupted when an entity is harmed, e.g. by an attack
    -- at the same time, sleeping will allow health recovery over time
    local sleep = function(self, turns) 
        sleep_turns = turns or SLEEP_TURNS
    
        local current, total = entity:getComponent(Health):getValue()
        local missing = total - current
        local rate = mfloor(sleep_turns / missing)

        -- generate a health recovery table, that indicates, per turn, how much health is recovered
        recovery = {}
        for i = 1, sleep_turns do
            local gain = 0

            if i % rate == 0 then gain = gain + 1 end

            table.insert(recovery, gain)
        end
    end

    -- check whether the entity is sleeping
    local isSleeping = function(self, turns) return sleep_turns > 0 end

    -- check whether the entity is engaged in combat, which for PC will never be true
    -- for NPC it will be true if the NPC sees player and starts chasing player
    local inCombat = function(self)
        if entity:getComponent(Health):isAlive() then
            for _, input_mode in ipairs(input_modes) do
                if input_mode:inCombat() then return true end
            end
        end

        return false
    end

    -- interrupt sleep, if the entity is sleeping, otherwise nothing happens
    local awake = function(self) sleep_turns = 0 end

    return setmetatable({             
        -- methods
        awake       = awake,
        addAP       = addAP,
        getAP       = getAP,
        sleep       = sleep,
        update      = update,
        inCombat    = inCombat,
        setAction   = setAction,
        getAction   = getAction,
        isSleeping  = isSleeping,
        setEnabled  = setEnabled,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})
