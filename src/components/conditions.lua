--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Conditions = {}

Conditions.new = function(entity, def)
    local conditions = {}
    local turn_idx = 0

    local add = function(self, condition)
        print('add condition with key: ', condition:getKey())    

        conditions[condition:getKey()] = condition

        Signal.emit('conditions', entity)            
    end

    local remove = function(self, key)
        -- e.g. when using dispel
        print('remove condition with key: ', key)

        conditions[key] = nil

        Signal.emit('conditions', entity)            
    end

    local update = function(self, dt, level)
        local level_turn_idx = level:getScheduler():getTurnIndex()

        if turn_idx == level_turn_idx then return end

        for key, condition in pairs(conditions) do
            if condition:isExpired(level:getScheduler():getTime()) then
                self:remove(key)
            end
        end

        turn_idx = level_turn_idx
    end

    local get = function(self, prop)
        local values = {}

        for key, condition in pairs(conditions) do
            if condition:getProperty() == prop then
                values[key] = condition:getValue()
            end
        end

        return values
    end

    local getIcons = function(self)
        local icons = {}

        for key, condition in pairs(conditions) do
            local icon = condition:getIcon()
            if icon then table.insert(icons, icon) end
        end

        return icons
    end

    return setmetatable({
        -- methods        
        add         = add,
        get         = get,
        remove      = remove,
        update      = update,
        -- TODO: cleaner to have an iterator method perhaps?
        getIcons    = getIcons,
    }, Conditions)
end

return setmetatable(Conditions, {
    __call = function(_, ...) return Conditions.new(...) end,
})
