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

function Level.new(dungeon)
    -- generate a map
    local tiles, stair_up, stair_dn = MazeGenerator.generate(MAP_SIZE, 5)
    local map = Map(tiles, function(id) return id ~= 0 end)
    local map_w, map_h = map:getSize()

    -- generate stairs using coords from maze generator
    stair_up = EntityFactory.create('dun_14', stair_up)
    stair_dn = EntityFactory.create('dun_13', stair_dn)

    -- keep track of entities
    local entities = { stair_up, stair_dn }

    -- add camera
    local camera = newCamera(4.0)

    -- setup ecs
    local systems = initSystems(entities)

    local update = function(self, dt)
        lume.each(systems, 'update', dt, self)
    end

    local draw = function(self)
        camera:attach()

        map:draw()

        lume.each(entities, 'draw')

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

    local getEntity = function(self)
        return nil
    end

    local enter = function(self, player)
        player.coord = stair_up.coord:clone()

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
