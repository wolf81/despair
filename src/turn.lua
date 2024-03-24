local Turn = {}

Turn.new = function(level, actors)
    actors = actors or {}

    local actions, active_idx, is_finished = {}, #actors, #actors == 0

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
                table.insert(actions, action)
                active_idx = active_idx - 1
            end

            ::continue::
        end

        -- execute actions for all actors simultaneously 
        if #actors == #actions then
            local duration = 0.2

            for i = #actions, 1, -1 do
                actions[i]:execute(duration)
                table.remove(actions, i)
            end

            -- reset actor list so we can start next turn
            Timer.after(duration, function() 
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