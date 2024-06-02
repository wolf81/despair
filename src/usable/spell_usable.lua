--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local SpellUsable = {}

local SPELL_TYPE_INFO = {
    ['shield-of-faith'] = ShieldOfFaith,
    ['magic-missile']   = MagicMissile,
    ['resistance']      = Resistance,
    ['mage-armor']      = MageArmor,
    ['light']           = Light,
}

SpellUsable.new = function(entity, def)
    -- the caster of a spell, could be a player, npc, wand, ...
    local use = function(self, caster, target_coord, level, duration)
        local T = SPELL_TYPE_INFO[entity.id]

        local spell = T(level, caster, entity, target_coord)
        spell:cast(duration)

        return false
    end

    return setmetatable({
        -- methods
        use = use,
    }, SpellUsable)
end

return setmetatable(SpellUsable, {
    __call = function(_, ...) return SpellUsable.new(...) end,
})
