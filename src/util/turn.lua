--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Turn = {}

local index = 1

local function sortByInitiative(actors)
    for i = 2, #actors, 1 do
        local c1 = actors[i - 1]:getComponent(Control)
        local c2 = actors[i]:getComponent(Control)

        if c1:getInitiative() > c2:getInitiative() then
            actors[i - 1], actors[i] = actors[i], actors[i - 1]
        end 
    end
end

Turn.new = function(level, actors, duration)
    actors = actors or {}
    index = index + 1

    sortByInitiative(actors)

    local time, active_idx, is_finished = 0, #actors, false

    local update = function(self, dt)        
        if is_finished then return end

        time = time + dt

        -- get actions for each actor
        while active_idx > 0 do
            local actor = actors[active_idx]  
            local control = actor:getComponent(Control)
            local action = control:getAction(level)
            if action == nil and time > duration then
                action = Move(level, actor, actor.coord)
            end

            if action == nil then break end

            action:execute(TURN_DURATION)
            active_idx = active_idx - 1
        end

        -- if all actors have performed their actions
        if active_idx == 0 then
            Timer.after(TURN_DURATION, function() 
                is_finished = true
            end)
        end
    end

    local isFinished = function() return is_finished end

    local getIndex = function() return index end

    return setmetatable({
        -- methods
        isFinished  = isFinished,
        getIndex    = getIndex,
        update      = update,
    }, Turn)
end

return setmetatable(Turn, {
    __call = function(_, ...) return Turn.new(...) end,
})
