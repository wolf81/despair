--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Game = {}

local function initSystems(entities)
    local inputSystem = System(Input)
    local intellectSystem = System(Intellect)
    local visualSystem = System(Visual)
    
    for _, entity in ipairs(entities) do
        intellectSystem:addComponent(entity)
        visualSystem:addComponent(entity)
        inputSystem:addComponent(entity)
    end

    return { intellectSystem, inputSystem, visualSystem }
end

local function newCamera(coord, zoom)
    local pos = coord * TILE_SIZE
    local camera = Camera(pos.x + TILE_SIZE / 2, pos.y + TILE_SIZE / 2)
    camera:zoomTo(zoom or 1.0)
    return camera
end

local function drawGrid(map_w, map_h)
    love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
    for y = 1, map_w do
        love.graphics.line(TILE_SIZE, y * TILE_SIZE, (map_w + 1) * TILE_SIZE, y * TILE_SIZE)
    end
    for x = 1, map_h do
        love.graphics.line(x * TILE_SIZE, TILE_SIZE, x * TILE_SIZE, (map_h + 1) * TILE_SIZE)
    end
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

function Game.new()
    -- generate a map
    local tiles = MapGenerator.generate(MAP_SIZE)
    local map = Map(tiles, function(id) return id == 1 end)
    local map_w, map_h = map:size()

    -- generate entities
    local player = EntityFactory.create('pc1', vector(8, 6))
    local entities = { player }

    -- add camera
    local camera = newCamera(player.coord, 3)

    -- setup ecs
    local systems = initSystems(entities)

    local update = function(self, dt)
        lume.each(systems, 'update', dt, self)
    end

    local draw = function(self)
        camera:attach()

        local texture = TextureCache:get('world')
        local quads = QuadCache:get('world')
        for y = 1, map_w do
            for x = 1, map_h do
                local tile_id = tiles[y][x]
                local quad_idx = 73

                if tile_id == math.huge then goto continue end

                if tile_id ~= 0 then
                    quad_idx = 1
                    if y < map_h then
                        if tiles[y + 1][x] == 1 then
                            quad_idx = 8
                        end
                    end
                end

                love.graphics.draw(texture, quads[quad_idx], x * TILE_SIZE, y * TILE_SIZE)

                ::continue::
            end
        end

        -- drawGrid(map_w, map_h)

        lume.each(entities, 'draw')

        camera:detach()
    end

    local isBlocked = function(self, coord)
        return map:isBlocked(coord.x, coord.y)
    end

    local setBlocked = function(self, coord, flag)
        map:setBlocked(coord.x, coord.y, flag)
    end

    local getEntity = function(self)
        return nil
    end

    local moveCamera = function(self, coord, duration)
        local pos = coord * TILE_SIZE
        local offset = TILE_SIZE / 2
        Timer.tween(duration, camera, { x = pos.x + offset, y = pos.y + offset })
    end

    return setmetatable({
        -- methods
        update      = update,
        draw        = draw,
        isBlocked   = isBlocked,
        setBlocked  = setBlocked,
        getEntity   = getEntity,
        moveCamera  = moveCamera,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
