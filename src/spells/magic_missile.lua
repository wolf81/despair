--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MagicMissile = {}

local function getLevel(entity)
    local class = entity:getComponent(Class)
    local npc = entity:getComponent(NPC)
    return class:getLevel() or npc:getLevel()
end

local function getAngle(coord1, coord2)
    coord1 = vector(coord1.x + 0.5, coord1.y + 0.5)
    coord2 = vector(coord2.x + 0.5, coord2.y + 0.5)            

    --[[
    effect:getComponent(Visual):setRotation(math.atan2(dxy.x, -dxy.y) + math.pi / 2)
    effect.coord = coord1
    --]]

    local dxy = coord1 - coord2
    local angle = math.atan2(dxy.x, -dxy.y) + math.pi / 2

    print('angle:', angle, coord1:angleTo(coord2), coord2:angleTo(coord1))

    return angle
end

MagicMissile.new = function(level, entity, coord)
    local level = getLevel(entity)

    local texture = TextureCache:get('uf_fx')
    local quads = QuadCache:get('uf_fx') -- 81

    local cast = function(self, duration, fn)
        print('cast magic missile')

        Timer.after(duration, fn)
        --Timer.tween(duration, entity, { coord = coord }, 'linear', fn)
    end

    return setmetatable({
        -- methods
        cast    = cast,
    }, MagicMissile)
end

return setmetatable(MagicMissile, {
    __call = function(_, ...) return MagicMissile.new(...) end,
})
