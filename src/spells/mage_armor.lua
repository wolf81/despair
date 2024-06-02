--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MageArmor = {}

local AC_BONUS = 4

MageArmor.new = function(level, caster, spell, target_coord)
    local spell_level = EntityHelper.getLevel(caster) or 1

    local cast = function(self, duration)
        -- TODO: should reduce remaining duration upon sleep, as sleep last 8 hours
        -- duration: 1 hour (3600 seconds) per level
        local exp_time = level:getScheduler():getTime() + spell_level * 3600
                
        local modify_ac = Modify(spell['id'], spell['name'], 'ac', AC_BONUS, exp_time)

        -- configure icon
        modify_ac:setIcon(TextureGenerator.generateImage('uf_interface', 403))

        local conditions = caster:getComponent(Conditions)
        conditions:add(modify_ac)
    end

    return setmetatable({
        -- methods
        cast = cast,
    }, MageArmor)
end

return setmetatable(MageArmor, {
    __call = function(_, ...) return MageArmor.new(...) end,
})
