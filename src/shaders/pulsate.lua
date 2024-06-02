--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Pulsate = {}

Pulsate.new = function()
    local is_finished = false

    local shader = ShaderCache:get('fade') 

    local alpha = 1.0
    local is_incr = false
    
    local isFinished = function(self) return is_finished end

    local update = function(self, dt)
        if is_incr then
            alpha = math.min(alpha + dt, 0.75)
            if alpha == 0.75 then is_incr = false end
        else
            alpha = math.max(alpha - dt, 0.25)
            if alpha == 0.25 then is_incr = true end
        end
    end

    local set = function(self)
        love.graphics.setShader(shader)
        shader:send('alpha', alpha)
    end

    local unset = function(self)
        love.graphics.setShader()
    end

    return setmetatable({
        -- methods
        set         = set,
        unset       = unset,
        update      = update,
        isFinished  = isFinished,        
    }, Pulsate)
end

return setmetatable(Pulsate, {
    __call = function(_, ...) return Pulsate.new(...) end,
})
