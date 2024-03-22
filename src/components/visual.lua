--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Visual = {}

Visual.getAnimKey = function(dir)
    -- TODO: should be hash table for speedy lookup
    if dir == Direction.S then return 'anim_s' end
    if dir == Direction.E then return 'anim_e' end
    if dir == Direction.N then return 'anim_n' end
    if dir == Direction.W then return 'anim_w' end
    return 'anim_s'
end

function Visual.new(entity, def)
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
