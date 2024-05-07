--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Race = {}

RACES = TableHelper.readOnly({
    ['halfling']    = true,
    ['human']       = true,
    ['dwarf']       = true,
    ['elf']         = true,
})

Race.new = function(entity, def)
    local race = def['race']
    assert(race ~= nil, 'missing field: "race"')
    assert(RACES[race] ~= nil, 'invalid race "' .. race .. '"')

    local getSkillBonus = function(self, skill) return race == 'human' and 1 or 0 end

    local getRaceName = function(self) return race end

    return setmetatable({
        -- methods
        getSkillBonus   = getSkillBonus,
        getRaceName     = getRaceName,
    }, Race)
end

return setmetatable(Race, {
    __call = function(_, ...) return Race.new(...) end,
})
