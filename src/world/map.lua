--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Map = {}

function Map.new(tiles, fn)
    fn = fn or function(id) return false end

    local height, width = #tiles, #tiles[1]
    local blocked = {}

    for y = 1, height do
        blocked[y] = {}
        for x = 1, width do
            blocked[y][x] = fn(tiles[y][x]) == true
        end
    end

    local setBlocked = function(self, x, y, flag) 
        blocked[y][x] = (flag == true)
    end

    local isBlocked = function(self, x, y)
        return blocked[y][x]
    end

    local getSize = function(self)
        return width, height
    end

    -- use a sprite batch for world texture, to efficiently draw the same quad multiple times
    local worldSprites = love.graphics.newSpriteBatch(TextureCache:get('uf_terrain'))

    local draw = function(self, show_grid)
        worldSprites:clear()

        local texture = TextureCache:get('uf_terrain')
        local quads = QuadCache:get('uf_terrain')
        for y = 1, self.height do
            for x = 1, self.width do
                local tile_id = tiles[y][x]

                if tile_id == math.huge then goto continue end

                local quad_idx = 22

                if tile_id ~= 0 then
                    quad_idx = 342
                    if y < height and tiles[y + 1][x] == 1 then
                        quad_idx = 322
                    end
                end

                worldSprites:add(quads[quad_idx], x * TILE_SIZE, y * TILE_SIZE)

                ::continue::
            end
        end

        love.graphics.draw(worldSprites)

        if show_grid == true then
            love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
            for y = 1, self.width do
                love.graphics.line(
                    TILE_SIZE, 
                    y * TILE_SIZE, 
                    (self.width + 1) * TILE_SIZE, 
                    y * TILE_SIZE)
            end
            for x = 1, self.height do
                love.graphics.line(
                    x * TILE_SIZE, 
                    TILE_SIZE, 
                    x * TILE_SIZE, 
                    (self.height + 1) * TILE_SIZE)
            end
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    return setmetatable({
        -- properties
        width       = width,
        height      = height,
        -- methods
        setBlocked  = setBlocked,
        isBlocked   = isBlocked,
        getSize     = getSize,
        draw        = draw,
    }, Map)
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
