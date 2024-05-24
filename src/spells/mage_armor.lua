--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MageArmor = {}

MageArmor.new = function(level, entity, coord)
    local cast = function(self, duration)
        print('cast mage armor')
    end

    return setmetatable({
        -- methods
        cast = cast,
    }, MageArmor)
end

return setmetatable(MageArmor, {
    __call = function(_, ...) return MageArmor.new(...) end,
})
