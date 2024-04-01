local Scheduler = {}

Scheduler.new = function(entities)
    entities = entities or {}

    local removed, last_entity = {}, nil

    -- local pqueue = PriorityQueue('min')
    local list = LinkedList()

    for _, entity in ipairs(entities) do
        local control = entity:getComponent(Control)
        if control == nil then goto continue end

        list:push(entity)

        ::continue::
    end

    local update = function(self, dt, level)
        local entity = list:shift()

        if not entity then return end

        local control = entity:getComponent(Control)

        if entity ~= last_entity then
            -- TODO: should skip check if only 1 entity, e.g. player?
            control:addAP(30)
            last_entity = entity
        end

        if control:getAP() >= 0 then
            local action = control:getAction(level)

            if action then
                action:execute(TURN_DURATION)     
                if control:getAP() >= 0 then
                    list:unshift(entity)
                else
                    list:push(entity)
                end       
            else
                list:unshift(entity)
            end
        else
            list:push(entity)
        end
    end

    local addEntity = function(self, entity)
        local control = entity:getComponent(Control)

        if control ~= nil then
            list:push(entity)
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