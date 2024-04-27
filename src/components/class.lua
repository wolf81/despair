local Class = {}

Class.new = function(entity, def)
    local class = def['class']
    assert(class ~= nil, 'missing field "class"')
    assert(CLASSES[class] ~= nil, 'invalid class "' .. class .. '"')

    local levelUp = function(self, level)
        local exp_level = entity:getComponent(ExpLevel)

        local health = entity:getComponent(Health)
        local current, total = health:getValue()
        local gain = ndn.dice('1d6').roll()
        health:increase(gain)

        if level % 3 == 0 then
            -- TODO: increase STR, DEX or MIND by 1
        end

        if class == 'fighter' and level % 5 == 0 then
            -- TODO: increase attack and damage by 1
        elseif class == 'cleric' and level % 2 == 1 then
            -- TODO: add new spells every uneven level
        elseif class == 'mage' then
            -- TODO: add new spells every uneven level
        end
    end

    return setmetatable({
        levelUp = levelUp,
    }, Class)
end

return setmetatable(Class, {
    __call = function(_, ...) return Class.new(...) end,
})
