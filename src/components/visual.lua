--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Visual = {}

Visual.new = function(entity, def, duration)
    local frames = def['anim'] or { 1 }

    local shader = ShaderCache:get('color_mix') 

    duration = duration or ANIM_DURATION

    local texture = TextureCache:get(def.texture)
    local quads = QuadCache:get(def.texture)
    local anim = Animation(frames, duration)
    local angle, ox, oy = 0, 0, 0

    -- properties for shader
    local props = {
        alpha = 1.0,
        blend_factor = 0.0,
        blend_color = { 1.0, 0.0, 0.0, 1.0 },
    }

    local quad_w, quad_h = select(3, quads[1]:getViewport())

    local anim_handle = nil

    update = function(self, dt, level)
        anim:update(dt) 
    end

    draw = function(self)
        love.graphics.setShader(shader)
        shader:send('blendColor', props.blend_color)
        shader:send('blendFactor', props.blend_factor)
        shader:send('alpha', props.alpha)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        local pos = entity.coord * TILE_SIZE

        anim:draw(texture, quads, pos, angle, ox, oy)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.setShader()

        local health_bar = entity:getComponent(HealthBar)
        if health_bar then health_bar:draw(props.alpha) end
    end

    colorize = function(self, duration)
        assert(duration ~= nil, 'missing argument: "duration"')

        if props.blend_factor ~= 0 then return end

        Timer.tween(duration / 2, props, { blend_factor = 0.8 }, 'linear', function() 
            Timer.tween(duration / 2, props, { blend_factor = 0.0 }, 'linear', function() 
                blend_factor = 0
            end)
        end)
    end

    pulsate = function(self)
        -- if shaders['pulsate'] then return end

        -- shaders['pulsate'] = Pulsate()
    end

    fadeOut = function(self, duration)
        if props.alpha == 0.0 then return end

        if anim_handle then Timer.cancel(anim_handle) end

        anim_handle = Timer.tween(duration, props, { alpha = 0.0 }, 'linear', function()
            anim_handle = nil 
        end)
    end

    fadeIn = function(self, duration)
        if props.alpha == 1.0 then return end

        if anim_handle then Timer.cancel(anim_handle) end

        anim_handle = Timer.tween(duration, props, { alpha = 1.0 }, 'linear', function() 
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

    setAlpha = function(self, alpha)
        fade.alpha = alpha
    end

    getSize = function(self) return quad_w, quad_h end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        fadeIn      = fadeIn,
        fadeOut     = fadeOut,
        getSize     = getSize,
        pulsate     = pulsate,
        colorize    = colorize,
        setAlpha    = setAlpha,
        setShader   = setShader,
        setOffset   = setOffset,
        setRotation = setRotation,
    }, Visual)
end

return setmetatable(Visual, { 
    __call = function(_, ...) return Visual.new(...) end, 
})
