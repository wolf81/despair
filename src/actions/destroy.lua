--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Destroy = {}

Destroy.new = function(level, entity)
    local did_execute = false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        Signal.emit('destroy', entity, duration)

        local visual = entity:getComponent(Visual)
        visual:fadeOut(duration)
    end

    return setmetatable({
        -- methods
        execute = execute,
    }, Destroy)
end

return setmetatable(Destroy, {
    __call = function(_, ...) return Destroy.new(...) end,
})
