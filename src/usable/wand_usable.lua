--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local WandUsable = {}

WandUsable.new = function(entity, def)
    assert(def.spell ~= nil, 'missing field: "spell"')

    -- TODO: for spells add target flags, e.g. self, ground, enemy, ...
    -- depending on target flags, make use function work or fail
    local spell = EntityFactory.create(def.spell)

    local use = function(self, source, target, level, duration)
        -- for spell animation, ensure wand coord is same as caster coord
        -- the source of the spell will be the wand, not the wielder of the wand
        entity.coord = source.coord:clone()

        return SpellUsable(spell):use(entity, target, level, duration)
    end

    return setmetatable({
        -- methods
        use = use,
    }, WandUsable)
end

return setmetatable(WandUsable, {
    __call = function(_, ...) return WandUsable.new(...) end,
})
