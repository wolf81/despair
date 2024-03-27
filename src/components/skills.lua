--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Skills = {}

Skills.new = function(entity, def)
    local class = def['class']
    local level = def['level']
    local race = def['race']

    -- for humans add +1 to each skill
    if race == 'human' then level = level + 1 end

    local skills = {
        phys = level + class == 'fighter' and 3 or 0,
        comm = level + class == 'cleric' and 3 or 0,
        subt = level + class == 'rogue' and 3 or 0,
        know = level + class == 'mage' and 3 or 0,
    }

    local getValue = function(self, skill)
        return skills[skill]
    end

    return setmetatable({
        -- methods
        getValue = getValue,
    }, Skills)
end

return setmetatable(Skills, {
    __call = function(_, ...) return Skills.new(...) end, 
})
