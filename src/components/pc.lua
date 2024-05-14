local PC = {}

PC.new = function(entity, def)
    local portrait_id = def['portrait_id']

    local gender = def['gender']
    local race = entity:getComponent(Race):getRaceName()
    local class = entity:getComponent(Class):getClassName()

    local portrait = Portrait(gender, race, class)
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
