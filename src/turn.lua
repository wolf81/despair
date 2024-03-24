local Turn = {}

Turn.new = function(level, actors)
    actors = actors or {}

    local active_idx, is_finished = #actors, false

    update = function(self, dt)
        if is_finished then return end

        -- get actions for each actor, in order
        while active_idx > 0 do
            local actor = actors[active_idx]  
            local control = actor:getComponent(Control)
            local action = control:getAction(level)
            if action == nil then
                break
            else
                action:execute(TURN_DURATION)
                active_idx = active_idx - 1
            end
        end

        if active_idx == 0 then
            Timer.after(TURN_DURATION, function() 
                is_finished = true
            end)
        end
    end

    local isFinished = function() 
        return is_finished 
    end

    return setmetatable({
        -- methods
        isFinished  = isFinished,
        update      = update,
    }, Turn)
end

return setmetatable(Turn, {
    __call = function(_, ...) return Turn.new(...) end,
})
