--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Skills = {}

-- TODO: maybe Class component should initialize with correct values based on class, race or hd
Skills.new = function(entity, def)
    local class = entity:getComponent(Class)
    local race = entity:getComponent(Race)
    local npc = entity:getComponent(NPC)

    -- add bonuses based on race and class, if applicable
    local phys, comm, subt, know = 0, 0, 0, 0
    
    if race then
        phys = phys + race:getSkillBonus('phys')
        comm = comm + race:getSkillBonus('comm')
        subt = subt + race:getSkillBonus('subt')
        know = know + race:getSkillBonus('know')
    end

    if class then
        phys = phys + class:getSkillBonus('phys')   
        comm = comm + class:getSkillBonus('comm')
        subt = subt + class:getSkillBonus('subt')
        know = know + class:getSkillBonus('know')
    end

    local skills = {
        phys = phys,
        comm = comm,
        subt = subt,
        know = know,
    }

    local getValue = function(self, skill)
        local base = 0
        if npc then base = base + npc:getLevel() end
        if class then base = base + class:getLevel() end

        return base + skills[skill]
    end

    return setmetatable({
        -- methods
        getValue = getValue,
    }, Skills)
end

return setmetatable(Skills, {
    __call = function(_, ...) return Skills.new(...) end, 
})
