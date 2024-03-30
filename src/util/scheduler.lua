local Scheduler = {}

Scheduler.new = function(entities)
    entities = entities or {}

    local removed, time = {}, 0

    local pqueue = PriorityQueue('min')

    for _, entity in ipairs(entities) do
        local control = entity:getComponent(Control)
        if control == nil then goto continue end

        pqueue:enqueue(entity, 0)

        ::continue::
    end

    local update = function(self, dt, level)
        time = time + dt

        if pqueue:empty() then return end

        local entity, prio = pqueue:dequeue()

        if removed[entity] then 
            removed[entity] = nil
            return
        end

        local control = entity:getComponent(Control)
        local action = control:getAction(level)

        if action == nil then
            pqueue:enqueue(entity, 0)
        else
            action:execute(TURN_DURATION, function()
                print('cost', action:getCost())
                pqueue:enqueue(entity, action:getCost())
            end)
        end
    end

    local addEntity = function(self, entity)
        local control = entity:getComponent(Control)

        if control ~= nil then
            pqueue:enqueue(entity, 0)
        end
    end

    local removeEntity = function(self, entity)
        removed[entity] = true
    end

    return setmetatable({
        -- methods
        update          = update,
        addEntity       = addEntity,
        removeEntity    = removeEntity
    }, Scheduler)
end

return setmetatable(Scheduler, {
    __call = function(_, ...) return Scheduler.new(...) end,
})