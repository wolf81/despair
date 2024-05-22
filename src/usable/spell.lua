--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Spell = {}

Spell.new = function(entity, def)
    print(entity.name)

    local use = function(source, target, level, duration)
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
