--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Colorize = {}

local FADE_IN_PARAMS = {
    ['blendColor'] = { 1.0, 0.0, 0.0, 0.8 }, 
    ['alpha'] = 1.0,
}

local FADE_OUT_PARAMS = {
    ['blendColor'] = { 1.0, 0.0, 0.0, 0.0 }, 
    ['alpha'] = 1.0,                        
}

Colorize.new = function(duration)
    local is_finished = false

    local shader = ShaderCache:get('color_mix') 

    local params = {
        ['blendColor'] = { 1.0, 0.0, 0.0, 0.0 },
        ['alpha'] = 1.0, 
    }

    local half_duration = duration / 2

    -- fade in to color ...
    Timer.tween(half_duration, params, FADE_IN_PARAMS, 'out-quad', function() 
        -- fade out to color ...
        Timer.tween(half_duration, params, FADE_OUT_PARAMS, 'in-quad', function() 
            is_finished = true
        end)
    end)

    local isFinished = function(self) return is_finished end

    local set = function(self)
        love.graphics.setShader(shader)
        for k, v in pairs(params) do
            shader:send(k, v)
        end
    end

    local unset = function(self)
        love.graphics.setShader()
    end

    return setmetatable({
        -- methods
        set         = set,
        unset       = unset,
        isFinished  = isFinished,
    }, Colorize)
end

return setmetatable(Colorize, {
    __call = function(_, ...) return Colorize.new(...) end,
})
