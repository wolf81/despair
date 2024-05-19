--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local PC = {}

GENDERS = TableHelper.readOnly({
    ['male']    = true,
    ['female']  = true,
})

PC.new = function(entity, def)
    local portrait_id = def['portrait_id']

    local gender = def['gender']
    assert(gender ~= nil, 'missing field: "gender"')
    assert(GENDERS[gender], 'invalid gender: "' .. gender .. '"')

    local race = entity:getComponent(Race)
    assert(race ~= nil, 'missing component: "Race"')

    local class = entity:getComponent(Class)
    assert(class ~= nil, 'missing component: "Class"')

    local portrait = Portrait(gender, race:getRaceName(), class:getClassName())
    portrait:setIdentifier(portrait_id)

    local getPortrait = function(self) return portrait end

    local getGender = function(self) return gender end

    return setmetatable({
        -- methods
        getGender   = getGender,
        getPortrait = getPortrait,
    }, PC)
end

return setmetatable(PC, {
    __call = function(_, ...) return PC.new(...) end,
})
