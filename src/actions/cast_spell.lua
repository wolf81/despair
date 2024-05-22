--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local CastSpell = {}

local SPELLS = {
    ['magic_missile'] = MagicMissile,
}

CastSpell.new = function(level, entity, coord, spell_id)
    local is_finished, did_execute = false, false

    assert(spell_id ~= nil, 'missing argument: "name"')
    assert(coord ~= nil, 'missing argument: "coords"')
    assert(SPELLS[spell_id] ~= nil, 'invalid spell: "' .. spell_id .. '"')

    local spell = SPELLS[spell_id](level, entity, coord)    

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        Signal.emit('cast_spell', entity, spell)

        spell:cast(duration, function() is_finished = true end)
    end

    local getAP = function(self) return ActionHelper.getSpellCost(entity) end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        getAP       = getAP,
        execute     = execute,
        isFinished  = isFinished,
    }, CastSpell)
end

return setmetatable(CastSpell, {
    __call = function(_, ...) return CastSpell.new(...) end,
})
