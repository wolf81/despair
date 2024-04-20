local matan2 = math.atan2

local HALF_PI = math.pi / 2

local M = {}

-- TODO: split in 2 methods: show effect & show projectile, will make it easier to use for usable 
-- abilities & maybe spells.
M.showEffect = function(effect, level, duration, target_coord, origin_coord)
    assert(effect ~= nil, 'missing argument: "effect"')
    assert(level ~= nil, 'missing argument: "level"')
    assert(duration ~= nil, 'missing argument: "duration"')
    assert(target_coord ~= nil, 'missing argument: "target_coord"')

    local is_projectile = FlagsHelper.hasFlag(effect.flags, FLAGS.projectile)
    if is_projectile then
        assert(origin_coord ~= nil, 'missing argument: "origin_coord"')

        origin_coord = vector(origin_coord.x + 0.5, origin_coord.y + 0.5)
        target_coord = vector(target_coord.x + 0.5, target_coord.y + 0.5)            

        local dxy = origin_coord - target_coord
        effect:getComponent(Visual):setRotation(matan2(dxy.x, -dxy.y) + HALF_PI)
        effect.coord = origin_coord

        level:addEntity(effect)
        Timer.tween(duration, effect, { coord = target_coord }, 'out-quad', function() 
            level:removeEntity(effect)
        end)
    else
        effect.coord = target_coord:clone()
        level:addEntity(effect)
        Timer.after(duration, function()
            level:removeEntity(effect)
        end)
    end            
end

return M
