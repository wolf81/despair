--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Use = {}

Use.new = function(level, entity, item, target)
    local did_execute, is_finished = false, false

    -- target self if target entity is not defined
    target = target or entity

    local usable = item:getComponent(Usable)
    usable:expend()    

    --[[
    -- TODO: should add a 'use' action to player (same for food, potions, etc...)
    -- the 'use' action should be activated next turn
    usable:use(target_coord, level)
    --]]

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        usable:use(target, level)

        -- use wand on enemy
        -- use potion on Kendrick
        -- use tome on ..?
        Signal.emit('use', entity, item, target)

        local effect = usable:getEffect()
        if effect ~= nil then
            local is_proj = FlagsHelper.hasFlag(effect.flags, FLAGS.projectile)

            if is_proj then
                local start_coord = entity.coord:clone()
                local end_coord = target:clone()

                -- local angle = start_coord:angleTo(end_coord)
                local dxy = start_coord - end_coord
                local rot = math.atan2(dxy.x, -dxy.y) + math.pi / 2

                effect:getComponent(Visual)
                    :setRotation(rot)
                    :setOffset(TILE_SIZE / 2, TILE_SIZE / 2)
                
                effect.coord = start_coord
                -- move projectile from start coord to end coord
                level:addEntity(effect)

                Timer.tween(duration, effect, { coord = end_coord }, 'in-quad', function() 
                    level:removeEntity(effect)
                end)
            end
        end

        Timer.after(duration, function()
            is_finished = true

            if fn then fn() end            
        end)
    end

    local getAP = function(self) return ActionHelper.getUseCost(entity) end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        getAP       = getAP,
        execute     = execute,
        isFinished  = isFinished,
    }, Use)
end

return setmetatable(Use, {
    __call = function(_, ...) return Use.new(...) end,
})
