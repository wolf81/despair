--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Conditions = {}

Conditions.new = function(entity, def)
    local conditions = {}
    local turn_idx = 0

    local add = function(self, condition, turns)
        print('add condition: ', condition)    

        conditions[condition] = turns
    end

    local remove = function(self, T)
        -- e.g. when using dispel
        print('remove condition of type: ', T)

        for condition in pairs(conditions) do
            if getmetatable(condition) == T then
                table.remove(conditions, condition)
                break
            end
        end
    end

    local update = function(self, dt, level)
        local level_turn_idx = level:getScheduler():getTurnIndex()

        if turn_idx == level_turn_idx then return end

        local finished = {}

        for condition, turns in pairs(conditions) do
            local next_turns = turns - 1
            conditions[condition] = next_turns
            if next_turns == 0 then table.insert(finished, condition) end
        end

        for idx = #finished, 1, -1 do
            table.remove(conditions, finished[idx])
        end

        turn_idx = level_turn_idx
    end

    return setmetatable({
        -- methods        
        add     = add,
        remove  = remove,
        update  = update,
    }, Conditions)
end

return setmetatable(Conditions, {
    __call = function(_, ...) return Conditions.new(...) end,
})
