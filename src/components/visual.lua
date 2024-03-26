--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Visual = {}

Visual.new = function(entity, def, duration)
    local frames = def['anim'] or { 1 }

    local shader_info = {
        shader = nil,
        params = {},
    }

    duration = duration or ANIM_DURATION

    if entity.type == 'effect' then
        duration = duration / #frames
    end

    local texture = TextureCache:get(def.texture)
    local quads = QuadCache:get(def.texture)
    local anim = Animation.loop(frames, duration)

    update = function(self, dt, level) 
        self.anim:update(dt)
    end

    draw = function(self)
        if shader_info.shader ~= nil then
            love.graphics.setShader(shader_info.shader)
            for k, v in pairs(shader_info.params) do
                shader_info.shader:send(k, v)
            end
        end

        love.graphics.setColor(1.0, 1.0, 1.0, self.alpha)
        local pos = entity.coord * TILE_SIZE
        self.anim:draw(texture, quads, pos)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.setShader()
    end

    colorize = function(self, duration)
        assert(duration ~= nil, 'missing parameter "duration"')

        -- prevent shader from triggering multiple times while one is busy
        if shader_info.shader ~= nil then return end

        -- setup shader and default param values
        shader_info.shader = ShaderCache:get('color_mix')
        shader_info.params = {
            ['blendColor']  = { 1.0, 0.0, 0.0, 0.0 },
            ['alpha']       = 1.0,
        }

        local half_duration = duration / 2
        Timer.tween(
            -- fade in the color
            half_duration, 
            shader_info.params, 
            {
                ['blendColor'] = { 1.0, 0.0, 0.0, 0.8 }, 
                ['alpha'] = 1.0,
            }, 
            'out-quad', 
            function() 
                Timer.tween(
                    -- fade out the color
                    half_duration,
                    shader_info.params,
                    {
                        ['blendColor'] = { 1.0, 0.0, 0.0, 0.0 }, 
                        ['alpha'] = 1.0,                        
                    },
                    'in-quad',
                    function()                        
                        shader_info.shader = nil
                    end
                )
            end)
    end

    fadeOut = function(self, duration)
        self.anim = Animation.fadeOut(def['anim'] or { 1 }, duration)
    end

    return setmetatable({
        -- properties
        alpha       = 1.0,
        anim        = anim,
        -- methods
        update      = update,
        draw        = draw,
        fadeOut     = fadeOut,
        setShader   = setShader,
        colorize    = colorize,
    }, Visual)
end

return setmetatable(Visual, { 
    __call = function(_, ...) return Visual.new(...) end, 
})
