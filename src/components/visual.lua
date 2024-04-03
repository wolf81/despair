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

    local texture = TextureCache:get(def.texture)
    local quads = QuadCache:get(def.texture)
    local anim = Animation.loop(frames, duration)
    local rot, ox, oy = 0, 0, 0

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
        self.anim:draw(texture, quads, pos, rot, ox, oy)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.setShader()

        local health_bar = entity:getComponent(HealthBar)
        if health_bar then health_bar:draw() end
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
        self.anim = Animation.fadeOut(def['anim'] or { 1 }, duration)
    end

    setRotation = function(self, angle)
        rot, ox, oy = angle, 0, 0

        if angle ~= 0 then 
            local _, _, quad_w, quad_h = quads[1]:getViewport()
            ox, oy = mfloor(quad_w / 2), mfloor(quad_h / 2)
        end

    end

    return setmetatable({
        -- properties
        alpha       = 1.0,
        anim        = anim,
        -- methods
        setRotation = setRotation,
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
