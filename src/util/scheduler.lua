--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Scheduler = {}

Scheduler.new = function()
    local turn, turn_finished = nil, true
    local entities, entity_idx = {}, 0

    local in_combat = false

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

    local update = function(self, level)
        if #entities == 0 then return end

        if not turn or turn:isFinished() then 
            if turn then in_combat = turn:inCombat() end
            
            turn = Turn(entities, level) 
            Signal.emit('turn', turn:getIndex())            
        end

        if not turn:isFinished() then turn:update() end
    end

    local inCombat = function(self) return in_combat end

    local getTurnIndex = function(self) return turn and turn:getIndex() or 0 end

    return setmetatable({
        -- methods
        update          = update,
        inCombat        = inCombat,
        addEntity       = addEntity,
        removeEntity    = removeEntity,
        getTurnIndex    = getTurnIndex,
    }, Scheduler)
end

return setmetatable(Scheduler, {
    __call = function(_, ...) return Scheduler.new(...) end,
})
