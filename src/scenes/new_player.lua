local NewPlayer = {}

NewPlayer.new = function()
    -- screen 1:
    -- gender: male / female
    -- race: human, elf, dwarf, halfling (+ gnome, half-orc, lizardman, half-elf)
    -- class: fighter, rogue, mage, cleric (+ paladin, bard, druid, ranger, illusionist)
    -- show skills & modifiers based on above
    -- (half-elves can choose any 2 skills, so should be choosable as well in some situations)

    -- name (allow for random generation based on gender + race)
    -- portrait 
    -- attr: STR / MIND / DEX

    return setmetatable({
    }, NewPlayer)
end

return setmetatable(NewPlayer, {
    __call = function(_, ...) return NewPlayer.new(...) end,
})
