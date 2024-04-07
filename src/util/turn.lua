local Turn = {}

local turn_idx = 0

Turn.new = function(entities, level)
    turn_idx = turn_idx + 1

    local entities = { unpack(entities) }
    local entity_idx = #entities
    local is_finished = #entities == 0

    local update = function(self)
        for i = #entities, 1, -1 do
            local entity = entities[i]
            local control = entity:getComponent(Control)
            if control:performAction(level) then
                table.remove(entities, i)
            else
                break
            end
        end

        is_finished = #entities == 0
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
