local Scheduler = {}

Scheduler.new = function()
    local turn_idx, turn_finished = 0, true
    local entities, entity_idx = {}, 0

    local addEntity = function(self, entity)
        local control = entity:getComponent(control)
        if entity:getComponent(Control) then
            table.insert(entities, entity)
        end
    end

    local removeEntity = function(self, entity)
        for idx, e in ipairs(entities) do
            if e == entity then
                table.remove(entities, idx)
                break
            end
        end
    end

    local update = function(self, dt, level)
        if #entities == 0 then return end

        if turn_finished then
            turn_idx = turn_idx + 1
            entity_idx = 1

            Signal.emit('turn', turn_idx)

            -- TODO: sort entities by initiative
            -- table.sort(entities, function(a, b) return true end)
        end

        local entity = entities[entity_idx]
        local control = entity:getComponent(Control)
        local success = control:performAction(level)

        if success then
            turn_finished = entity_idx == #entities
            entity_idx = entity_idx + 1

            if not turn_finished then
                self:update(dt, level)
            end
        end
    end

    local getTurnIndex = function(self) return turn_idx end

    return setmetatable({
        -- methods
        update          = update,
        addEntity       = addEntity,
        removeEntity    = removeEntity,
        getTurnIndex    = getTurnIndex,
    }, Scheduler)
end

return setmetatable(Scheduler, {
    __call = function(_, ...) return Scheduler.new(...) end,
})
