--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Light = {}

Light.new = function(level, entity, coord)
    local cast = function(self, duration)
        print('cast light')

        --Timer.tween(duration, entity, { coord = coord }, 'linear', fn)
    end

    return setmetatable({
        -- methods
        cast = cast,
    }, Light)
end

return setmetatable(Light, {
    __call = function(_, ...) return Light.new(...) end,
})
