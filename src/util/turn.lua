local Turn = {}

local turn_idx = 0

Turn.new = function(entities, level)
    turn_idx = turn_idx + 1

    local entities = { unpack(entities) }
    local entity_idx = #entities
    local is_finished = #entities == 0

    local entity_count = #entities
    local actions = {}

    table.sort(entities, function(a, b) 
        return a.type ~= 'pc' and b.type == 'pc' 
    end)

    local update = function(self)
        if is_finished then return end

        for i = #entities, 1, -1 do
            local entity = entities[i]
            local control = entity:getComponent(Control)
            local action = control:getAction(level)
            if action then 
                if getmetatable(action) == Destroy then
                    action:execute(0.2)
                    entity_count = entity_count - 1
                else
                    table.insert(actions, action) 
                end

                table.remove(entities, i)
            end
        end

        if #actions == entity_count then
            for _, action in ipairs(actions) do
                action:execute(0.2)
            end

            Timer.after(0.2, function() 
                is_finished = true
            end)
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
