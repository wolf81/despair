--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local CastSpell = {}

local SPELLS = {
    ['magic_missile'] = MagicMissile,
}

CastSpell.new = function(level, entity, coord, spell_id)
    assert(spell_id ~= nil, 'missing argument: "name"')
    assert(coord ~= nil, 'missing argument: "coords"')
    assert(SPELLS[spell_id] ~= nil, 'invalid spell: "' .. spell_id .. '"')

    local spell = SPELLS[spell_id](level, entity, coord)

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        -- body
    end

    return setmetatable({
        -- methods
        draw    = draw,
        update  = update,
    }, CastSpell)
end

return setmetatable(CastSpell, {
    __call = function(_, ...) return CastSpell.new(...) end,
})
