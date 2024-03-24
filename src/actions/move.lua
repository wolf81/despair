local Move = {}

Move.new = function(entity, coord)
    local did_execute = false

    local execute = function(self, level, duration)
        if did_execute then return end

        did_execute = true

        Timer.tween(duration, entity, { coord = coord }, 'linear', function() 
            entity.coord = coord
        end)

        -- TODO: use Signal here instead
        if entity.type == 'pc' then
            level:moveCamera(coord, duration)
        end
    end

    return setmetatable({
        -- methods
        execute = execute,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
