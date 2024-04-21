local Sleep = {}

Sleep.new = function(player)
    local game = nil

    local alpha = 0.0

    local draw = function(self)
        game:draw()
    end

    local update = function(self, dt)
        game:update(dt)
    end

    local enter = function(self, from)
        game = from

        player:getComponent(Control):setEnabled(false)
        game:setActionsEnabled(false)        
    end

    local leave = function(self, to)
        player:getComponent(Control):setEnabled(true)
        game:setActionsEnabled(true)

        game = nil
    end

    return setmetatable({
        -- methods
        draw    = draw,
        enter   = enter,
        leave   = leave,
        update  = update,
    }, Sleep)
end

return setmetatable(Sleep, {
    __call = function(_, ...) return Sleep.new(...) end,
})
