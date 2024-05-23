--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Resistance = {}

Resistance.new = function(level, entity, coord)
    local cast = function(self, duration)
        print('cast resistance')
    end

    return setmetatable({
    }, Resistance)
end

return setmetatable(Resistance, {
    __call = function(_, ...) return Resistance.new(...) end,
})
