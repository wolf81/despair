--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, lrandom = math.floor, love.math.random

local Level = {}

--[[
local function newMonsters(coords)
    local monsters = {}

    for i = 1, mfloor(math.sqrt(#coords / 2)) do
        local type = i % 2 == 0 and 'bat' or 'spider'
        local monster = EntityFactory.create(type, table.remove(coords, lrandom(#coords)))
        table.insert(monsters, monster)
    end

    return monsters
end
--]]

local function initSystems(entity_manager)
    local inputSystem = System(Input)
    local visualSystem = System(Visual)
    local intellectSystem = System(Intellect)

    for entity in entity_manager:eachEntity() do
        intellectSystem:addComponent(entity)
        visualSystem:addComponent(entity)
        inputSystem:addComponent(entity)
    end    

    return { intellectSystem, inputSystem, visualSystem }
end

local function getKey(coord)
    return coord.x .. ':' .. coord.y
end

function Level.new(dungeon)
    -- generate a map
    local tiles, stair_up, stair_dn = MazeGenerator.generate(MAP_SIZE, 5)
    local map = Map(tiles, function(id) return id ~= 0 end)
    local map_w, map_h = map:getSize()

    local entity_manager = EntityManager()

    -- generate stairs using coords from maze generator
    stair_up = EntityFactory.create('dun_14', stair_up)
    stair_dn = EntityFactory.create('dun_13', stair_dn)

    entity_manager:addEntity(stair_up)
    entity_manager:addEntity(stair_dn)

    -- add camera
    local camera = Camera(0.0, 0.0, CAMERA_ZOOM)

    -- setup ecs
    local systems = initSystems(entity_manager)

    local addEntity = function(self, entity)
        for _, system in ipairs(systems) do
            system:addComponent(entity)
        end

        entity_manager:addEntity(entity)
    end

    local removeEntity = function(self, entity)
        for _, system in ipairs(systems) do
            system:removeComponent(entity)
        end

        entity_manager:removeEntity(entity)
    end

    local updateEntity = function(self, entity)        
        entity_manager:updateEntity(entity)
    end

    local update = function(self, dt)
        for _, system in ipairs(systems) do
            system:update(dt, self)
        end
    end

    local draw = function(self)
        camera:attach()

        map:draw()
        entity_manager:draw()

        camera:detach()
    end

    local isBlocked = function(self, coord)
        if coord.x < 1 or coord.x > map_w then return true end
        if coord.y < 1 or coord.y > map_h then return true end   
        return map:isBlocked(coord.x, coord.y)
    end

    local setBlocked = function(self, coord, flag)
        map:setBlocked(coord.x, coord.y, flag)
    end

    local getEntities = function(self, coord)
        return entity_manager:getEntities(coord)
    end

    local enter = function(self, player)
        player.coord = stair_up.coord:clone()

        self:addEntity(player)

        -- move player to stairs and focus camera on player
        self:moveCamera(player.coord, 0)
    end

    local exit = function(self, player)
        self:removeEntity(player)
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
        update          = update,
        draw            = draw,
        isBlocked       = isBlocked,
        setBlocked      = setBlocked,
        moveCamera      = moveCamera,
        enter           = enter,
        exit            = exit,
        addEntity       = addEntity,
        getEntities     = getEntities,
        removeEntity    = removeEntity,
        updateEntity    = updateEntity,
    }, Level)
end

return setmetatable(Level, { 
    __call = function(_, ...) return Level.new(...) end,
})
