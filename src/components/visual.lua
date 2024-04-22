--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Visual = {}

Visual.new = function(entity, def, duration)
    local frames = def['anim'] or { 1 }

    local shader_info = {
        shader = nil,
        params = {},
    }

    duration = duration or ANIM_DURATION

    local texture = TextureCache:get(def.texture)
    local quads = QuadCache:get(def.texture)
    local anim = Animation(frames, duration)
    local angle = 0
    local ox, oy = 0, 0

    local fade = { alpha = 0.0 }

    local _, _, quad_w, quad_h = quads[1]:getViewport()

    local anim_handle = nil

    update = function(self, dt, level) anim:update(dt) end

    draw = function(self)
        if shader_info.shader ~= nil then
            love.graphics.setShader(shader_info.shader)
            for k, v in pairs(shader_info.params) do
                shader_info.shader:send(k, v)
            end
        end

        love.graphics.setColor(1.0, 1.0, 1.0, fade.alpha)
        local pos = entity.coord * TILE_SIZE

        anim:draw(texture, quads, pos, angle, ox, oy)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.setShader()

        local health_bar = entity:getComponent(HealthBar)
        if health_bar then health_bar:draw(fade.alpha) end
    end

    colorize = function(self, duration)
        assert(duration ~= nil, 'missing argument "duration"')

        -- prevent shader from triggering multiple times while one is busy
        if shader_info.shader ~= nil then return end

        -- setup shader and default param values
        shader_info.shader = ShaderCache:get('color_mix')
        shader_info.params = {
            ['blendColor']  = { 1.0, 0.0, 0.0, 0.0 },
            ['alpha']       = 1.0,
        }

        local fade_in_params = {
            ['blendColor'] = { 1.0, 0.0, 0.0, 0.8 }, 
            ['alpha'] = 1.0,
        }

        local fade_out_params = {
            ['blendColor'] = { 1.0, 0.0, 0.0, 0.0 }, 
            ['alpha'] = 1.0,                        
        }

        local time = duration / 2

        -- fade in to color ...
        Timer.tween(time, shader_info.params, fade_in_params, 'out-quad', function() 
            -- fade out to color ...
            Timer.tween(time, shader_info.params, fade_out_params, 'in-quad', function() 
                shader_info.shader = nil 
            end)
        end)
    end

    fadeOut = function(self, duration)
        if fade.alpha == 0.0 then return end

        if anim_handle then Timer.cancel(anim_handle) end

        anim_handle = Timer.tween(duration, fade, { alpha = 0.0 }, 'linear', function()
            anim_handle = nil 
        end)
    end

    fadeIn = function(self, duration)
        if fade.alpha == 1.0 then return end

        if anim_handle then Timer.cancel(anim_handle) end

        anim_handle = Timer.tween(duration, fade, { alpha = 1.0 }, 'linear', function() 
            anim_handle = nil
        end)
    end

    setRotation = function(self, angle_)
        angle = angle_
        return self
    end

    setOffset = function(self, x, y)
        ox, oy = x, y
        return self
    end

    getSize = function(self) return quad_w, quad_h end

    return setmetatable({
        -- methods
        update      = update,
        draw        = draw,
        fadeIn      = fadeIn,
        fadeOut     = fadeOut,
        getSize     = getSize,
        colorize    = colorize,
        setShader   = setShader,
        setOffset   = setOffset,
        setRotation = setRotation,
    }, Visual)
end

return setmetatable(Visual, { 
    __call = function(_, ...) return Visual.new(...) end, 
})
