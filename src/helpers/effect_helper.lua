--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local matan2 = math.atan2

local HALF_PI = math.pi / 2

local M = {}

M.showProjectile = function(effect, level, duration, origin_coord, target_coord)
    assert(effect ~= nil, 'missing argument: "effect"')
    assert(level ~= nil, 'missing argument: "level"')
    assert(duration ~= nil, 'missing argument: "duration"')
    assert(origin_coord ~= nil, 'missing argument: "origin_coord"')
    assert(target_coord ~= nil, 'missing argument: "target_coord"')

    -- projectiles start from center of tile, move towards target center of tile
    origin_coord = vector(origin_coord.x + 0.5, origin_coord.y + 0.5)
    target_coord = vector(target_coord.x + 0.5, target_coord.y + 0.5)

    local visual = effect:getComponent(Visual)

    -- adjust offset to take into account projectile image size
    local w, h = effect:getComponent(Visual):getSize() 
    visual:setOffset((TILE_SIZE - w) / 2, (TILE_SIZE - h) / 2)

    -- rotate projectile towards angle 
    local dxy = origin_coord - target_coord
    visual:setRotation(matan2(dxy.x, -dxy.y) + HALF_PI)

    effect.coord = origin_coord

    -- TODO: projectiles should have a constant speed, related to distance
    level:addEntity(effect)
    Timer.tween(duration, effect, { coord = target_coord }, 'out-quad', function() 
        level:removeEntity(effect)
    end)    
end

M.showEffect = function(effect, level, duration, coord, offset)
    assert(effect ~= nil, 'missing argument: "effect"')
    assert(level ~= nil, 'missing argument: "level"')
    assert(duration ~= nil, 'missing argument: "duration"')
    assert(coord ~= nil, 'missing argument: "coord"')

    local visual = effect:getComponent(Visual)
    local eff_w, eff_h = visual:getSize()

    local ox, oy = 0, 0
    if eff_w ~= TILE_SIZE or eff_h ~= TILE_SIZE then
        ox, oy = (TILE_SIZE - eff_w) / TILE_SIZE / 2, (TILE_SIZE - eff_h) / TILE_SIZE / 2
    end

    -- TODO: maybe add scatter flag that shows multiple effects near coord?
    -- e.g. in case of lightning on a single tile, could be arranged 2 by 2:

    effect.coord = vector(coord.x + ox, coord.y + oy)
    level:addEntity(effect)
    Timer.after(duration, function()
        level:removeEntity(effect)
    end)
end

return M
