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
        love.graphics.setColor(1.0, 1.0, 1.0, alpha)
        local pos = entity.coord * TILE_SIZE
        self.anim:draw(texture, quads, pos)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    fadeOut = function(self, duration)
        self.anim = Animation.fadeOut(def['anim'] or { 1 }, duration)
    end

    return setmetatable({
        -- properties
        anim    = anim,
        -- methods
        update  = update,
        draw    = draw,
        fadeOut = fadeOut,
    }, Visual)
end

return setmetatable(Visual, { 
    __call = function(_, ...) return Visual.new(...) end, 
})
