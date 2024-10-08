--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MoveSpeed = {}

MoveSpeed.new = function(entity, def)
    local speed = def.speed

    local getValue = function() return 30 / speed * 30 end

    return setmetatable({
        -- methods
        getValue = getValue,
    }, MoveSpeed)
end

return setmetatable(MoveSpeed, {
    __call = function(_, ...) return MoveSpeed.new(...) end,
})
