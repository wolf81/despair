--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MagicMissile = {}

local function getLevel(entity)
    local class = entity:getComponent(Class)
    if class then return class:getLevel() end

    local npc = entity:getComponent(NPC)
    if npc then return npc:getLevel() end

    return 1
end

local function getEntity(level, coord)
    local entities = level:getEntities(coord, function(entity) 
        return entity.type == 'pc' or entity.type == 'npc'
    end)

    return #entities > 0 and entities[1] or nil
end

MagicMissile.new = function(level, source, entity, target_coord)
    local spell_level = getLevel(source)

    -- create an effect at runtime
    local effect = EntityFactory.create({
        id      = 'ef_' .. entity.id,
        texture = 'uf_fx',
        anim    = { 81 },
    })
    effect:getComponent(Visual):setAlpha(0.8)

    local cast = function(self, duration)
        local entity = getEntity(level, target_coord)
        if entity ~= nil then
            local damage = ndn.dice('1d4+1').roll()
            entity:getComponent(Health):harm(damage)

            EffectHelper.showProjectile(effect, level, duration, source.coord, target_coord)
            return true
        end

        return false
    end

    return setmetatable({
        -- methods
        cast    = cast,
    }, MagicMissile)
end

return setmetatable(MagicMissile, {
    __call = function(_, ...) return MagicMissile.new(...) end,
})
