--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Spell = {}

local SPELL_TYPE_INFO = {
    ['shield-of-faith'] = ShieldOfFaith,
    ['magic-missile']   = MagicMissile,
    ['resistance']      = Resistance,
    ['mage-armor']      = MageArmor,
    ['light']           = Light,
}

Spell.new = function(entity, def)
    local use = function(self, source, target, level, duration)
        local T = SPELL_TYPE_INFO[entity.id]

        local spell = T(level, source, entity, target)
        spell:cast(duration)

        return false
    end    

    return setmetatable({
        -- methods
        use = use,
    }, Spell)
end

return setmetatable(Spell, {
    __call = function(_, ...) return Spell.new(...) end,
})
