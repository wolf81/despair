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
            local visual = effect:getComponent(Visual)
            local eff_w, eff_h = visual:getSize()

            if is_proj then
                local start_coord = vector(entity.coord.x + 0.5, entity.coord.y + 0.5)
                local end_coord = vector(target.x + 0.5, target.y + 0.5)

                -- local angle = start_coord:angleTo(end_coord)
                local dxy = start_coord - end_coord
                visual:setRotation(math.atan2(dxy.x, -dxy.y) + math.pi / 2)
                
                effect.coord = start_coord
                -- move projectile from start coord to end coord
                level:addEntity(effect)

                Timer.tween(duration, effect, { coord = end_coord }, 'in-quad', function() 
                    level:removeEntity(effect)
                end)
            else
                local ox, oy = -TILE_SIZE / 2 + eff_w / 2, -TILE_SIZE / 2 + eff_h / 2
                visual:setOffset(ox, oy)

                effect.coord = target:clone()
                -- move projectile from start coord to end coord
                level:addEntity(effect)
                Timer.after(0.5, function() 
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
