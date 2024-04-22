--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Attack = {}

local getMainhandWeaponEffect = function(entity)
    local item = entity:getComponent(Equipment):getItem('mainhand')
 
    if item then
        return item:getComponent(Equippable):getEffect()
    end

    return nil
end

local function effectAsProjectile(effect, coord1, coord2)
    coord1 = vector(coord1.x + 0.5, coord1.y + 0.5)
    coord2 = vector(coord2.x + 0.5, coord2.y + 0.5)            

    local dxy = coord1 - coord2
    effect:getComponent(Visual):setRotation(math.atan2(dxy.x, -dxy.y) + math.pi / 2)
    effect.coord = coord1

    return coord2
end

Attack.new = function(level, entity, target)
    local did_execute, is_finished = false, false

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        local status = CombatResolver.resolve(entity, target)

        Signal.emit('attack', entity, target, status, duration)

        local effect = getMainhandWeaponEffect(entity)
        if effect then
            if FlagsHelper.hasFlag(effect.flags, FLAGS.projectile) then
                EffectHelper.showProjectile(effect, level, duration, entity.coord, target.coord)
            else
                EffectHelper.showEffect(effect, level, duration, target.coord)
            end
        end

        local is_hit, is_crit = false, false
        for _, attack in ipairs(status.attacks) do
            if attack.is_hit then is_hit = true end
            if attack.is_crit then is_crit = true end
        end

        -- visualize hit on target by drawing with a tint color
        if is_hit then target:getComponent(Visual):colorize(0.3) end

        -- show camera shake effect if player performs a critical hit
        if is_crit and entity == level:getPlayer() then level:shakeCamera(duration) end

        Timer.after(duration, function()
            is_finished = true
            
            if fn then fn() end
        end)
    end

    local getAP = function(self) return ActionHelper.getAttackCost(entity) end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        getAP       = getAP,
        execute     = execute,
        isFinished  = isFinished,
    }, Attack)
end

return setmetatable(Attack, { 
	__call = function(_, ...) return Attack.new(...) end,
})
