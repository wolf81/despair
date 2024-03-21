--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, mhuge = math.floor

local Level = {}

local function newEntities()
    local bat1 = EntityFactory.create('bat', vector(10, 10))
    local bat2 = EntityFactory.create('bat', vector(8, 5))
    local spider1 = EntityFactory.create('spider', vector(12, 10))
    local spider2 = EntityFactory.create('spider', vector(12, 12))
    return { bat1, bat2, spider1, spider2 }
end

local function initSystems(entities)
    local inputSystem = System(Input)
    local visualSystem = System(Visual)
    local intellectSystem = System(Intellect)
    
    for _, entity in ipairs(entities) do
        intellectSystem:addComponent(entity)
        visualSystem:addComponent(entity)
        inputSystem:addComponent(entity)
    end

    return { intellectSystem, inputSystem, visualSystem }
end

local function newCamera(zoom)
    local camera = Camera(0, 0)
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

function Level.new()
    -- generate a map
    local tiles = MapGenerator.generate(MAP_SIZE, 8)
    local map = Map(tiles, function(id) return id ~= 0 end)
    local map_w, map_h = map:getSize()

    -- generate entities
    local entities = newEntities()

    -- add camera
    local camera = newCamera(4.0)

    -- setup ecs
    local systems = initSystems(entities)

    local update = function(self, dt)
        lume.each(systems, 'update', dt, self)
    end

    local worldSprites = love.graphics.newSpriteBatch(TextureCache:get('world'))

    local draw = function(self)
        camera:attach()

        worldSprites:clear()

        local texture = TextureCache:get('world')
        local quads = QuadCache:get('world')
        for y = 1, map_w do
            for x = 1, map_h do
                local tile_id = tiles[y][x]
                local quad_idx = 73

                if tile_id == math.huge then goto continue end

                if tile_id ~= 0 then
                    quad_idx = 1
                    if y < map_h and tiles[y + 1][x] == 1 then
                        quad_idx = 8
                    end
                end

                worldSprites:add(quads[quad_idx], x * TILE_SIZE, y * TILE_SIZE)

                ::continue::
            end
        end

        love.graphics.draw(worldSprites)

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

    local enter = function(self, player)
        -- TODO: coord should be of stairs down
        player.coord = vector(8, 6)

        for _, system in ipairs(systems) do
            system:addComponent(player)
        end

        table.insert(entities, player)
        self:moveCamera(player.coord, 0)
    end

    -- add offset of half tile, as we want the camera to focus on middle of tile coord
    local cam_offset = TILE_SIZE / 2
    local moveCamera = function(self, coord, duration)
        local pos = coord * TILE_SIZE
        Timer.tween(duration, camera, { 
            x = mfloor(pos.x + cam_offset), 
            y = mfloor(pos.y + cam_offset),
        })
    end

    return setmetatable({
        -- methods
        update      = update,
        draw        = draw,
        isBlocked   = isBlocked,
        setBlocked  = setBlocked,
        getEntity   = getEntity,
        moveCamera  = moveCamera,
        enter       = enter,
    }, Level)
end

return setmetatable(Level, { 
    __call = function(_, ...) return Level.new(...) end,
})
