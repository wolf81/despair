--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Visual = {}

Visual.new = function(entity, def)
    local last_dir = nil

    local texture = TextureCache:get(def.texture)
    local quads = QuadCache:get(def.texture)
    local anim = Animation.loop(def['anim'] or { 1 })

    update = function(self, dt, level) 
        self.anim:update(dt)
    end

    draw = function(self)
        local pos = entity.coord * TILE_SIZE
        self.anim:draw(texture, quads, pos)
    end

    return setmetatable({
        -- properties
        anim = anim,
        -- methods
        update = update,
        draw = draw,
    }, Visual)
end

return setmetatable(Visual, { __call = function(_, ...) return Visual.new(...) end })
