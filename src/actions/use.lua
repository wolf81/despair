--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Use = {}

Use.new = function(level, entity, ability, target)
    local did_execute, is_finished = false, false

    --[[
    -- TODO: should add a 'use' action to player (same for food, potions, etc...)
    -- the 'use' action should be activated next turn
    usable:use(target_coord, level)
    --]]

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        -- use wand on enemy
        -- use potion on Kendrick
        -- use tome on ..?
        Signal.emit('use', entity, ability, target)

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
