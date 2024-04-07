local Scheduler = {}

Scheduler.new = function()
    local turn_idx, turn_finished = 0, true
    local turn = nil
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

        if not turn or turn:isFinished() then 
            turn = Turn(entities, level) 
            Signal.emit('turn', turn:getIndex())            
        end

        if not turn:isFinished() then 
            turn:update(dt)
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
