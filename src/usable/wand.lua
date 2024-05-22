--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Wand = {}

Wand.new = function(entity, def)
    local effect = nil

    if def.effect then
        effect = EntityFactory.create(def.effect)
    end

    local use = function(source, target, level, duration)
        local entities = level:getEntities(target, function(entity) 
            -- TODO: some wands might target walls or maybe empty space
            return entity.type == 'pc' or entity.type == 'npc'
        end)

        for _, entity in ipairs(entities) do
            local health = entity:getComponent(Health)
            local damage = ndn.dice('3d4').roll()
            health:harm(damage)
        end

        local effect = usable:getEffect()
        if effect ~= nil then
            if FlagsHelper.hasFlag(effect.flags, FLAGS.projectile) then
                EffectHelper.showProjectile(effect, level, 0.5, source.coord, target)
            else
                EffectHelper.showEffect(effect, level, 0.5, target)
            end
        end

        return false
    end

    return setmetatable({
        -- methods
        use = use,
    }, Wand)
end

return setmetatable(Wand, {
    __call = function(_, ...) return Wand.new(...) end,
})
