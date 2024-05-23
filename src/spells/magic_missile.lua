--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MagicMissile = {}

local function getLevel(entity)
    local class = entity:getComponent(Class)
    local npc = entity:getComponent(NPC)
    return class:getLevel() or npc:getLevel() or 1
end

local function getAngle(coord1, coord2)
    coord1 = vector(coord1.x + 0.5, coord1.y + 0.5)
    coord2 = vector(coord2.x + 0.5, coord2.y + 0.5)            

    --[[
    effect:getComponent(Visual):setRotation(math.atan2(dxy.x, -dxy.y) + math.pi / 2)
    effect.coord = coord1
    --]]

    local dxy = coord1 - coord2
    local angle = math.atan2(dxy.x, -dxy.y) + math.pi / 2

    print('angle:', angle, coord1:angleTo(coord2), coord2:angleTo(coord1))

    return angle
end

MagicMissile.new = function(level, source, entity, target_coord)
    local spell_level = getLevel(source)

    -- create an effect at runtime
    local effect = EntityFactory.create({
        id      = 'ef_' .. entity.id,
        texture = 'uf_fx',
        anim    = { 81 },
    })
    effect.flags = FlagsHelper.parseFlags({ 'PR' }, 'effect')

    local cast = function(self, duration)
        print('cast magic missile')
        EffectHelper.showProjectile(effect, level, duration, source.coord, target_coord)
    end

    return setmetatable({
        -- methods
        cast    = cast,
    }, MagicMissile)
end

return setmetatable(MagicMissile, {
    __call = function(_, ...) return MagicMissile.new(...) end,
})
