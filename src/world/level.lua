--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, matan2, lrandom = math.floor, math.atan2, love.math.random

local Level = {}

local function onDropItem(self, entity)
    if self:hasStairs(entity.coord) then
        print('it\'s not possible to drop items on stairs')
        return
    end
    
    local backpack = entity:getComponent(Backpack)
    local size = backpack:getSize()
    if size > 0 then backpack:dropItem(size, self) end
end

local function initSystems(entities)
    local visual_system, control_system = System(Visual), System(Control)
    local health_system, health_bar_system = System(Health), System(HealthBar)

    for _, entity in ipairs(entities) do
        visual_system:addComponent(entity)
        control_system:addComponent(entity)
        health_system:addComponent(entity)
        health_bar_system:addComponent(entity)
    end    

    return { visual_system, control_system, health_system, health_bar_system }
end

Level.new = function(dungeon, level_idx)
    assert(dungeon ~= nil, 'missing argument "dungeon"')
    assert(level_idx ~= nil, 'missing argument "level_idx"')

    -- generate a map
    local tiles, stair_up, stair_dn = MazeGenerator.generate(MAP_SIZE, 9)

    local map = Map(tiles, function(id) return id ~= 0 end)
    local map_w, map_h = map:getSize()
    local player_idx = 0

    -- generate a Dijkstra map for monsters movement towards / away from player
    local player_dist_map = DijkstraMap(
        tiles,                                      -- 2D tile map
        function(x, y) return tiles[y][x] == 1 end, -- check whether tile is blocked
        true,                                       -- include diagonal movement
        ORDINAL_MOVE_FACTOR)                        -- cost of diagonal moves

    -- generate stairs using coords from maze generator
    stair_up = EntityFactory.create('dun_14', stair_up)
    stair_dn = EntityFactory.create('dun_13', stair_dn)

    local entities = { stair_up, stair_dn }

    local scheduler = Scheduler()

    -- fog of war
    local fog = Fog(16, 10)

    -- add camera
    local camera = Camera(0.0, 0.0, 1.0)
    local follow = true

    -- setup ecs
    local systems = initSystems(entities)

    -- setup line of sight
    local shadowcaster = Shadowcaster(
        -- is visible
        function(x, y) return map:getTile(x, y) ~= 1 end, 
        -- cast light
        function(x, y) fog:reveal(x, y) end
    )

    local onPut = function(self, entity)
        print(entity.name .. ' added to backpack')
    end

    local onMove = function(self, entity, coord, duration)
        self:setBlocked(entity.coord, false)
        self:setBlocked(coord, true)

        if entity.type ~= 'pc' then
            if fog:isVisible(coord.x, coord.y) then
                entity:getComponent(Visual):fadeIn(0.2)
            else
                entity:getComponent(Visual):fadeOut(0.2)
            end

            return
        end

        -- about once every 15 turns, randomly spawn a monster if PC is not in combat 
        if not scheduler:inCombat() and lrandom(1, 25) == 1 then
            self:addEntity(EncounterGenerator.generate(self, coord, 10, 8))
        end

        -- update the player distance map, to help NPCs find player
        player_dist_map:update(coord.x, coord.y)

        -- update fog of war
        fog:cover()
        local radius = 8
        shadowcaster:castLight(coord.x, coord.y, radius)

        local cartographer = entity:getComponent(Cartographer)
        cartographer:updateChart(coord, map)

        for y = coord.y - radius - 3, coord.y + radius + 3 do
            for x = coord.x - radius - 3, coord.x + radius + 3 do
                local coord = vector(x, y)
                local is_visible = fog:isVisible(x, y)

                for _, entity in ipairs(self:getEntities(coord)) do
                    local visual = entity:getComponent(Visual)

                    if not visual then goto continue end

                    if is_visible then
                        visual:fadeIn(0)
                    else
                        visual:fadeOut(0)
                    end

                    ::continue::
                end
            end
        end

        camera:move(coord, duration)

        if entity.coord ~= coord then 
            local entities = self:getEntities(coord)
            if #entities > 0 then
                local target = entities[1]
                local item = target:getComponent(Item)
                local backpack = entity:getComponent(Backpack)

                if item then
                    Timer.after(duration, function()
                        self:removeEntity(target)
                        backpack:put(target)
                    end)
                end
            end

            if coord == stair_up.coord then
                self:setBlocked(coord, false)
                dungeon:prevLevel()
            elseif coord == stair_dn.coord then
                self:setBlocked(coord, false)
                dungeon:nextLevel()
            end
        end

        -- every step the player makes, consumes some energy
        entity:getComponent(Energy):expend()        
    end

    local onDestroy = function(self, entity, duration)
        print(entity.name .. ' is destroyed')
    end

    local onAttack = function(self, entity, target, status, duration)
        local is_hit, is_crit = false, false

        for _, attack in ipairs(status.attacks) do
            is_hit = is_hit or attack.is_hit
            is_crit = is_crit or attack.is_crit

            if attack.damage == 0 then
                print(entity.name .. ' missed attack on ' .. target.name)
            else
                if attack.is_crit then
                    print(entity.name .. ' critically hit ' .. target.name .. ' for ' .. attack.damage .. ' hitpoints')
                else
                    print(entity.name .. ' hit ' .. target.name .. ' for ' .. attack.damage .. ' hitpoints')
                end
            end

            local total = attack.roll + attack.attack
            print(total .. ' (' .. attack.roll .. ' + ' .. attack.attack .. ') vs ' .. status.ac)
        end
    end

    local onEnergy = function(self, entity, message)
        print(message)
    end

    local onIdle = function(self, entity, duration)
        if fog:isVisible(entity.coord.x, entity.coord.y) then
            print(entity.name .. ' is idling')
        end
    end

    local onTurn = function(self, turn_idx)
        print('TURN ' .. turn_idx)
    end

    local addEntity = function(self, entity)
        table.insert(entities, entity)

        -- a skip list would be useful here, to keep the list auto-sorted
        -- or use the priority queue instead
        table.sort(entities, function(a, b) return a.z_index < b.z_index end)    

        for _, system in ipairs(systems) do
            system:addComponent(entity)
        end

        for idx, entity in ipairs(entities) do
            if entity.type == 'pc' then
                player_idx = idx
                break
            end
        end

        scheduler:addEntity(entity)
    end

    local removeEntity = function(self, entity)    
        for idx, e in ipairs(entities) do
            if e == entity then
                if idx < player_idx then
                    player_idx = player_idx - 1                
                end
                table.remove(entities, idx)
            end
        end

        if entity.type == 'pc' then player_idx = 0 end

        scheduler:removeEntity(entity)

        for _, system in ipairs(systems) do
            system:removeComponent(entity)
        end
    end

    local update = function(self, dt)  
        if is_paused == true then return end      
        
        for i = #entities, 1, -1 do
            local entity = entities[i]
            if entity.remove then
                self:removeEntity(entity)
            end
        end

        for _, system in ipairs(systems) do
            system:update(dt, self)
        end

        scheduler:update(self)
    end

    local draw = function(self, x, y, w, h)
        camera:draw(function() 
            map:draw()

            for _, entity in ipairs(entities) do
                entity:draw()
            end

            local ox, oy = camera:getWorldCoords(0, 0)
            fog:draw(ox, oy)
        end, x, y, w, h)
    end

    local isBlocked = function(self, coord)
        if coord.x < 1 or coord.x > map_w then return true end
        if coord.y < 1 or coord.y > map_h then return true end   
        return map:isBlocked(coord.x, coord.y)
    end

    local inLineOfSight = function(self, coord1, coord2) 
        return bresenham.los(coord1.x, coord1.y, coord2.x, coord2.y, function(x, y) 
            return map:getTile(x, y) ~= 1
        end)
    end

    local isVisible = function(self, coord)
        return fog:isVisible(coord.x, coord.y)
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

    local getPlayer = function(self)
        return (player_idx > 0) and entities[player_idx] or nil
    end

    local shakeCamera = function(self, duration) camera:shake(duration) end

    local handles = {}

    local enter = function(self, player, direction)
        self:addEntity(player)

        if direction == 'up' then
            player.coord = stair_dn.coord:clone()        
        else
            player.coord = stair_up.coord:clone()        
        end

        self:setBlocked(player.coord, true)

        local handlers = {
            ['put']         = function(...) onPut(self, ...)     end,
            ['move']        = function(...) onMove(self, ...)    end,
            ['idle']        = function(...) onIdle(self, ...)    end,
            ['attack']      = function(...) onAttack(self, ...)  end,
            ['destroy']     = function(...) onDestroy(self, ...) end,
            ['energy']      = function(...) onEnergy(self, ...)  end,
            ['turn']        = function(...) onTurn(self, ...)    end,
            ['drop-item']   = function(...) onDropItem(self, ...) end
        }

        for action, handler in pairs(handlers) do
            handles[action] = Signal.register(action, handler)
        end

        local cartographer = player:getComponent(Cartographer)
        cartographer:setLevel(level_idx, function(x, y) 
            return fog:isVisible(x, y)
        end)
        cartographer:updateChart(player.coord, map)

        -- focus on player
        onMove(self, player, player.coord, 0)
    end

    local exit = function(self, player)        
        self:removeEntity(player)

        for action, handle in pairs(handles) do
            Signal.remove(action, handle)
        end
    end

    local getSize = function(self) return map_w, map_h end

    -- get the level coord for a position, e.g. mouse position
    local getCoord = function(self, x, y) 
        if x < 0 or y < 0 or x > WINDOW_W - STATUS_PANEL_W or y > WINDOW_H - ACTION_BAR_H then 
            return nil
        end

        x, y = camera:getWorldCoords(x, y)
        x = mfloor((x + STATUS_PANEL_W / 2) / TILE_SIZE)
        y = mfloor((y + ACTION_BAR_H / 2) / TILE_SIZE)

        return vector(x, y)
    end

    local getPlayerDistance = function(self, coord)
        return player_dist_map:getDistance(coord.x, coord.y)
    end

    local hasStairs = function(self, coord)
        return coord == stair_up.coord or coord == stair_dn.coord
    end

    local getScheduler = function(self) return scheduler end

    local getIndex = function(self) return level_idx end
    
    return setmetatable({
        -- methods
        draw                = draw,
        exit                = exit,
        enter               = enter,
        update              = update,
        getSize             = getSize,
        getIndex            = getIndex,
        getCoord            = getCoord,
        hasStairs           = hasStairs,
        isVisible           = isVisible,
        isBlocked           = isBlocked,
        getPlayer           = getPlayer,
        addEntity           = addEntity,
        setBlocked          = setBlocked,
        shakeCamera         = shakeCamera,
        getEntities         = getEntities,
        getScheduler        = getScheduler,
        removeEntity        = removeEntity,
        inLineOfSight       = inLineOfSight,
        getPlayerDistance   = getPlayerDistance,
    }, Level)
end

return setmetatable(Level, { 
    __call = function(_, ...) return Level.new(...) end,
})
