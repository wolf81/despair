--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, lrandom = math.floor, love.math.random

local Level = {}

local function newMonsters()
    local monsters = {}

    for x = 2, 23, 3  do
        local type = x % 2 == 0 and 'bat' or 'spider'
        local monster = EntityFactory.create(type, vector(x, 8))
        table.insert(monsters, monster)
    end

    return monsters
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

local function getKey(coord)
    return coord.x .. ':' .. coord.y
end

function Level.new(dungeon)
    -- generate a map
    local tiles, stair_up, stair_dn = MazeGenerator.generate(MAP_SIZE, 5)
    local map = Map(tiles, function(id) return id ~= 0 end)
    local map_w, map_h = map:getSize()

    -- generate stairs using coords from maze generator
    stair_up = EntityFactory.create('dun_14', stair_up)
    stair_dn = EntityFactory.create('dun_13', stair_dn)

    local entities = { stair_up, stair_dn }

    local active_idx = 0

    for _, monster in ipairs(newMonsters()) do
        table.insert(entities, monster)
        map:setBlocked(monster.coord.x, monster.coord.y, true)
    end

    -- add camera
    local camera = Camera(0.0, 0.0, CAMERA_ZOOM)

    -- setup ecs
    local systems = initSystems(entities)

    local addEntity = function(self, entity)
        table.insert(entities, entity)

        -- a skip list would be useful here, to keep the list auto-sorted
        table.sort(entities, function(a, b) return a.z_index < b.z_index end)

        for _, system in ipairs(systems) do
            system:addComponent(entity)
        end
    end

    local removeEntity = function(self, entity)
        for i, e in ipairs(entities) do
            if e == entity then
                table.remove(entities, i)
            end
        end

        for _, system in ipairs(systems) do
            system:removeComponent(entity)
        end
    end

    local actions, actors = {}, {}

    local update = function(self, dt)
        for _, system in ipairs(systems) do
            system:update(dt, self)
        end

        if #actors == 0 then
            for _, entity in ipairs(entities) do
                if entity:getComponent(Control) then
                    table.insert(actors, entity)
                end
            end

            active_idx = #actors
        end

        while active_idx > 0 do
            local actor = actors[active_idx]
            local control = actor:getComponent(Control)
            local action = control:getAction(self)
            if action == nil then
                break
            else
                table.insert(actions, action)
                active_idx = active_idx - 1
            end

            ::continue::
        end

        if #actors == #actions then
            local duration = 0.2

            for i = #actions, 1, -1 do
                actions[i]:execute(self, duration)
                table.remove(actions, i)
            end

            Timer.after(duration, function() 
                actors = {}                 
            end)
        end
    end

    local draw = function(self)
        camera:attach()

        map:draw()

        for _, entity in ipairs(entities) do
            entity:draw()
        end

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

    local getEntities = function(self, coord, fn)
        local filtered = {}

        fn = fn or function(e) return true end

        for _, entity in ipairs(entities) do
            if entity.coord == coord and fn(entity) then
                table.insert(filtered, entity)
            end
        end

        return filtered
    end

    local enter = function(self, player)
        player.coord = stair_up.coord:clone()

        self:addEntity(player)

        self:setBlocked(player.coord, true)

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
    }, Level)
end

return setmetatable(Level, { 
    __call = function(_, ...) return Level.new(...) end,
})
