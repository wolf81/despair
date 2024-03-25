local Destroy = {}

Destroy.new = function(level, entity)
    local did_execute = false

    local execute = function(self, duration)
        if did_execute then return end

        did_execute = true

        Signal.emit('destroy', entity, duration)

        -- TODO: fade out
        -- Timer.tween(duration, entity, { coord = coord }, 'linear', function() 
        --     entity.coord = coord
        -- end)
    end

    return setmetatable({
        -- methods
        execute = execute,
    }, Destroy)
end

return setmetatable(Destroy, {
    __call = function(_, ...) return Destroy.new(...) end,
})