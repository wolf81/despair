--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Map = {}

Map.new = function(grid)
    local height, width = #grid, #grid[1]
    local blocked = {}

    local tiles = TileGenerator.generate(grid)

    local theme = nil

    local is_grid_visible = false

    for y = 1, height do
        blocked[y] = {}
        for x = 1, width do
            blocked[y][x] = grid[y][x] == 1
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

    local getTile = function(self, x, y)
        return grid[y][x]
    end

    -- use a sprite batch for world texture, to efficiently draw the same quad multiple times
    local sprite_batch = love.graphics.newSpriteBatch(TextureCache:get('uf_terrain'))

    local draw = function(self, x1, y1, x2, y2)
        -- TODO: render only visible area, using x1, y1, x2, y2 for drawing rect
        sprite_batch:clear()

        local texture = TextureCache:get('uf_terrain')
        local quads = QuadCache:get('uf_terrain')
        for y = y1, y2 do
            for x = x1, x2 do
                local quad_idx = tiles[y][x]
                sprite_batch:add(quads[quad_idx], x * TILE_SIZE, y * TILE_SIZE)
            end
        end

        love.graphics.draw(sprite_batch)

        if is_grid_visible then
            love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
            for x = x1, x2 do
                love.graphics.line(
                    TILE_SIZE, 
                    y * TILE_SIZE, 
                    (self.width + 1) * TILE_SIZE, 
                    y * TILE_SIZE)
            end
            for y = y1, y2 do
                love.graphics.line(
                    x * TILE_SIZE, 
                    TILE_SIZE, 
                    x * TILE_SIZE, 
                    (self.height + 1) * TILE_SIZE)
            end
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    local setGridVisible = function(self, flag) is_grid_visible = (flag == true) end

    return setmetatable({
        -- methods
        draw            = draw,
        getTile         = getTile,
        getSize         = getSize,
        isBlocked       = isBlocked,
        setBlocked      = setBlocked,
        setGridVisible  = setGridVisible,
    }, Map)
end

return setmetatable(Map, {
    __call = function(_, ...) return Map.new(...) end,
})
