--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Spell = {}

Spell.new = function(entity, def)
    local cast = function(self)
        -- cast spell
    end

    return setmetatable({
        cast = cast,
    }, Spell)
end

return setmetatable(Spell, {
    __call = function(_, ...) return Spell.new(...) end,
})
