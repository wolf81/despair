--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local ShieldOfFaith = {}

ShieldOfFaith.new = function(level, entity, coord)
    local cast = function(self, duration)
        print('cast shield of faith')
    end

    return setmetatable({
        -- methods
        cast = cast,
    }, ShieldOfFaith)
end

return setmetatable(ShieldOfFaith, {
    __call = function(_, ...) return ShieldOfFaith.new(...) end,
})
