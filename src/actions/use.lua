--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Use = {}

Use.new = function(level, entity, item, target)
    local did_execute, is_finished = false, false

    -- target self if target entity is not defined
    target = target or entity

    local usable = item:getComponent(Usable)
    usable:expend()    

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        -- use wand on enemy
        -- use potion on Kendrick
        -- use tome on ..?
        -- use (cast) spell on ..?
        Signal.emit('use', entity, item, target)

        usable:use(entity, target, level, duration)

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
