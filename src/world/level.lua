--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, matan2, lrandom = math.floor, math.atan2, love.math.random

local Level = {}

local function newMonsters(map)
    local monsters = {}

    local types = { 
        'bat', 'blk_widow', 'skeleton', 'skel_mage', 'skel_warr', 
        'skel_arch', 'cobra', 'rat', 'green_ooze', 'red_drag',
        'wraith', 'vampire', 'vampire_lord', 'lich', 'dire_cobra',
        'dire_bat', 'blue_drag', 'orc_shaman', 'orc_warrior', 
        'purple_jelly', 'blk_widow_mat', 'spectator', 'observer'
    }

    while #monsters < 10 do
        local x = lrandom(map.width)
        local y = lrandom(map.height)

        if not map:isBlocked(x, y) then
            local type = types[lrandom(#types)]
            local monster = EntityFactory.create(type, vector(x, y))
            table.insert(monsters, monster)
        end        
    end

    return monsters
end

local function initSystems(entities)
    local visualSystem = System(Visual)

    for _, entity in ipairs(entities) do
        visualSystem:addComponent(entity)
    end    

    return { visualSystem }
end

Level.new = function(dungeon)
    -- generate a map
    local tiles, stair_up, stair_dn = MazeGenerator.generate(MAP_SIZE, 5)
    local map = Map(tiles, function(id) return id ~= 0 end)
    local map_w, map_h = map:getSize()
    local player_idx = 0

    -- generate stairs using coords from maze generator
    stair_up = EntityFactory.create('dun_14', stair_up)
    stair_dn = EntityFactory.create('dun_13', stair_dn)

    local entities = { stair_up, stair_dn }

    -- fog of war
    local fog = Fog(13, 10)

    for _, monster in ipairs(newMonsters(map)) do
        table.insert(entities, monster)
        map:setBlocked(monster.coord.x, monster.coord.y, true)

        local visual = monster:getComponent(Visual)
        visual.alpha = 0.0
    end

    local scheduler = Scheduler(entities)

    -- add camera
    local camera = Camera(0.0, 0.0, SCALE)
    local follow = true

    -- setup ecs
    local systems = initSystems(entities)

    -- setup line of sight
    local shadowcaster = Shadowcaster(
        -- is visible
        function(x, y) return map:getTile(x, y) == 0 end, 
        -- cast light
        function(x, y) fog:reveal(x, y) end
    )

    local onMove = function(self, entity, coord, duration)
        self:setBlocked(entity.coord, false)
        self:setBlocked(coord, true)

        if entity.type ~= 'pc' then 
            local prev_coord_visible = fog:isVisible(entity.coord.x, entity.coord.y)
            local next_coord_visible = fog:isVisible(coord.x, coord.y)
            if next_coord_visible and not prev_coord_visible then
                local visual = entity:getComponent(Visual)
                Timer.tween(duration, visual, { alpha = 1.0 }, 'linear')
            end

            if prev_coord_visible and not next_coord_visible then
                local visual = entity:getComponent(Visual)
                Timer.tween(duration, visual, { alpha = 0.0 }, 'linear')
            end

            return
        end

        -- update fog of war
        fog:cover()     
        local radius = 6   
        shadowcaster:castLight(coord.x, coord.y, radius)    

        for y = coord.y - radius - 1, coord.y + radius + 1 do
            for x = coord.x - radius - 1, coord.x + radius + 1 do
                if not fog:isVisible(x, y) then
                    -- hide any npcs here
                    for _, entity in ipairs(self:getEntities(vector(x, y))) do
                        if entity:getComponent(Control) then
                            local visual = entity:getComponent(Visual)
                            Timer.tween(duration, visual, { alpha = 0.0 }, 'linear')
                        end
                    end
                end

                if fog:isVisible(x, y) then
                    for _, entity in ipairs(self:getEntities(vector(x, y))) do
                        if entity:getComponent(Control) then
                            local visual = entity:getComponent(Visual)
                            Timer.tween(duration, visual, { alpha = 1.0 }, 'linear')
                        end
                    end
                end
            end
        end

        camera:move(coord, duration)

        if entity.coord ~= coord then 
            if coord == stair_up.coord then
                self:setBlocked(coord, false)
                dungeon:prevLevel()
            elseif coord == stair_dn.coord then
                self:setBlocked(coord, false)
                dungeon:nextLevel()
            end
        end
    end

    local onDestroy = function(self, entity, duration)
        print(entity.name .. ' is destroyed')

        Timer.after(duration, function() 
            self:setBlocked(entity.coord, false)
            entity.remove = true
        end)
    end

    local onAttack = function(self, entity, target, status, duration)
        if status.proj_id ~= nil and status.proj_id ~= '' then
            local coord1 = vector(entity.coord.x + 0.5, entity.coord.y + 0.5)
            local coord2 = vector(target.coord.x + 0.5, target.coord.y + 0.5)
            local projectile = EntityFactory.create(status.proj_id, coord1)            
            self:addEntity(projectile)
            local visual = projectile:getComponent(Visual)
            local rot = matan2(coord2.x - coord1.x, coord1.y - coord2.y) - math.pi / 2
            visual:setRotation(rot)

            Timer.tween(duration, projectile, { coord = coord2 }, 'linear', function()
                self:removeEntity(projectile)
            end)
        else
            local effect = EntityFactory.create('strike_1', target.coord:clone())
            self:addEntity(effect)
            Timer.after(duration, function() self:removeEntity(effect) end)        
        end

        if status.damage == 0 then
            print(entity.name .. ' missed attack on ' .. target.name)
        else
            local visual = target:getComponent(Visual)
            visual:colorize(duration)

            if status.is_crit then
                print(entity.name .. ' critically hit ' .. target.name .. ' for ' .. status.damage .. ' hitpoints')
            else
                print(entity.name .. ' hit ' .. target.name .. ' for ' .. status.damage .. ' hitpoints')
            end
        end

        local total = status.roll + status.attack
        print(total .. ' (' .. status.roll .. ' + ' .. status.attack .. ') vs ' .. status.ac)

        if status.is_crit then
            camera:shake(duration)
        end
    end

    local onIdle = function(self, entity, duration)
        print(entity.name .. ' is idling')
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

        for _, system in ipairs(systems) do
            system:removeComponent(entity)
        end

        scheduler:removeEntity(entity)
    end

    local update = function(self, dt)        
        for i = #entities, 1, -1 do
            local entity = entities[i]
            if entity.remove then
                self:removeEntity(entity)
            end
        end

        for _, system in ipairs(systems) do
            system:update(dt, self)
        end

        Pointer.update(camera, self)

        scheduler:update(dt, self)

        --[[
        if player_idx == 0 then return end

        -- create new turn if needed
        if turn:isFinished() then
            local actors = {} 
            
            for _, entity in ipairs(entities) do
                if entity:getComponent(Control) then
                    table.insert(actors, entity)
                end
            end

            turn = Turn(self, actors, TURN_DELAY)

            -- heal player 1 hitpoint every 5 turns
            if turn:getIndex() % 5 == 0 then
                local player_health = entities[player_idx]:getComponent(Health)
                player_health:heal(1)
            end
        end

        turn:update(dt)
        --]]
    end

    local draw = function(self)
        camera:draw(function() 
            map:draw()

            for _, entity in ipairs(entities) do
                entity:draw()
            end

            local ox, oy = camera:worldCoords(0, 0)
            fog:draw(ox, oy)
        end)
    end

    local isBlocked = function(self, coord)
        if coord.x < 1 or coord.x > map_w then return true end
        if coord.y < 1 or coord.y > map_h then return true end   
        return map:isBlocked(coord.x, coord.y)
    end

    local inLineOfSight = function(self, coord1, coord2) 
        return bresenham.los(coord1.x, coord1.y, coord2.x, coord2.y, function(x, y) 
            return map:getTile(x, y) == 0
        end)
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

    local handlers = {}

    local enter = function(self, player)
        self:addEntity(player)

        self:setBlocked(player.coord, true)

        handlers = {
            ['move']    = function(...) onMove(self, ...)    end,
            ['idle']    = function(...) onIdle(self, ...)    end,
            ['attack']  = function(...) onAttack(self, ...)  end,
            ['destroy'] = function(...) onDestroy(self, ...) end,
        }

        for key, handler in pairs(handlers) do
            Signal.register(key, handler)
        end

        -- focus on player
        onMove(self, player, player.coord, 0)
    end

    local exit = function(self, player)        
        self:removeEntity(player)

        for key, handler in pairs(handlers) do
            Signal.remove(key, handler)
        end
    end
    
    return setmetatable({
        -- properties
        entry_coord     = stair_up.coord,
        exit_coord      = stair_dn.coord,
        -- methods
        update          = update,
        draw            = draw,
        isBlocked       = isBlocked,
        setBlocked      = setBlocked,
        inLineOfSight   = inLineOfSight,
        enter           = enter,
        exit            = exit,
        addEntity       = addEntity,
        getPlayer       = getPlayer,
        getEntities     = getEntities,
        removeEntity    = removeEntity,
    }, Level)
end

return setmetatable(Level, { 
    __call = function(_, ...) return Level.new(...) end,
})
