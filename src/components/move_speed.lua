local MoveSpeed = {}

MoveSpeed.new = function(entity, def)
    local speed = def.speed

    local getValue = function() return speed / 30 end

    return setmetatable({
        -- methods
        getValue = getValue,
    }, MoveSpeed)
end

return setmetatable(MoveSpeed, {
    __call = function(_, ...) return MoveSpeed.new(...) end,
})
