--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Turn = {}

local turn_idx = 0

Turn.new = function(entities, level)
    turn_idx = turn_idx + 1

    -- create a shallow clone of entities table, to prevent modifying entities in Scheduler
    local entities = { unpack(entities) }

    -- remove player from entity list, as player will always start first
    local player = nil
    for idx, entity in ipairs(entities) do
        if entity.type == 'pc' then
            player = table.remove(entities, idx)
            break
        end
    end

    -- keep track if turn is finished (performed actions for all all entities)
    local is_finished = false

    -- keep track if player performed an action
    local is_waiting_for_player = true

    local turn_duration = TURN_DURATION

    local update = function(self)
        -- ensure a player is in play (not destroyed) and turn is not finished
        if (not player) or is_finished then return end

        -- ensure the player always performs the first action
        if is_waiting_for_player then
            local control = player:getComponent(Control)
            
            -- ensure the player has enough action points to perform a move, so AP > 0
            local ap = control:getAP()
            if ap <= 0 then control:addAP(-ap + 1) end

            local action = control:getAction(level)
            if action then
                local is_sleeping = getmetatable(action) == Rest

                -- while the player is sleeping, turns are instant
                turn_duration = is_sleeping and 0 or TURN_DURATION

                -- always immediately execute player action
                action:execute(turn_duration)
                is_waiting_for_player = false

                for _, entity in ipairs(entities) do
                    entity:getComponent(Control):addAP(action:getAP())
                end
            end  
        end

        -- after player performed an action, other entities can perform an action
        if not is_waiting_for_player then
            for _, entity in ipairs(entities) do
                local control = entity:getComponent(Control)
                local action = control:getAction(level)
                if action then action:execute(turn_duration) end
            end

            Timer.after(turn_duration, function() is_finished = true end)
        end
    end

    local getIndex = function(self) return turn_idx end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        update      = update,
        isFinished  = isFinished,
        getIndex    = getIndex,
    }, Turn)
end

return setmetatable(Turn, {
    __call = function(_, ...) return Turn.new(...) end,
})
