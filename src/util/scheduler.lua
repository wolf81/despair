local Scheduler = {}

Scheduler.new = function(entities)
    entities = entities or {}

    local list = LinkedList()
    local prev_entity, removed = nil, {}

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
        local health = entity:getComponent(Health)
        local player = level:getPlayer()

        -- add AP in 2 cases: 
        -- * active entity changed; to ensure entity uses up all AP 
        -- * only 1 entity active; to ensure the entity can perform actions 
        if list.length == 0 or entity ~= prev_entity then
            control:addAP(30)
            prev_entity = entity
        end

        -- if the entity doesn't have enough AP to perform an action, move to end of linked list
        if control:getAP() < 0 then
            return list:push(entity)
        end

        -- perform an action:
        -- * could be 'nil' while waiting for input
        -- * if input was received by Control component, will have an action
        local action = control:getAction(level)

        -- if no action, move to start of list until we get an action
        if not action then            
            return list:unshift(entity)
        end

        -- we did get an action, so execute over animation duration or 0 if far away from player
        local duration = TURN_DURATION
        if player and player.coord:dist(entity.coord) > 10 then
            duration = 0
        end
        action:execute(duration)

        -- if the entity was scheduled to be removed, don't re-add to list
        if removed[entity] then return end

        -- if we still have AP left after action is performed, move to start of linked list, 
        -- otherwise to end of linked list
        if control:getAP() > 0 then
            list:unshift(entity)
        else
            list:push(entity)
        end       
    end

    local addEntity = function(self, entity)
        local control = entity:getComponent(Control)

        -- add new entities at start of linked list
        if control ~= nil then
            list:unshift(entity)
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