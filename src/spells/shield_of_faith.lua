--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin, mfloor = math.min, math.floor

local ShieldOfFaith = {}

ShieldOfFaith.new = function(level, caster, spell, target_coord)
    local spell_level = EntityHelper.getLevel(caster) or 1

    -- TODO: add shimmering effect for duration, can we add 'outline' effect with shader
    local cast = function(self, duration)
        -- TODO: should reduce remaining duration upon sleep, as sleep last 8 hours
        -- duration: 1 minute (60 seconds) per level
        local exp_time = level:getScheduler():getTime() + spell_level * 60

        -- add 2 AC bonus + 1 for every 6 levels, with max bonus +5 at level 18
        local ac_bonus = 2 + mmin(mfloor(spell_level / 3), 3)

        local modify_ac = Modify(spell['id'], spell['name'], 'ac', ac_bonus, exp_time)

        -- configure icon
        modify_ac:setIcon(TextureGenerator.generateImage('uf_interface', 403))

        local conditions = caster:getComponent(Conditions)
        conditions:add(modify_ac)
    end

    return setmetatable({
        -- methods
        cast = cast,
    }, ShieldOfFaith)
end

return setmetatable(ShieldOfFaith, {
    __call = function(_, ...) return ShieldOfFaith.new(...) end,
})
