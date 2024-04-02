--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom = love.math.random

local MAX_ATTEMPTS = 10

local Dungeon = {}

local function weightedChoice(t)
    local sum = 0
    for _, v in pairs(t) do
        assert(v >= 0, "weight value less than zero")
        sum = sum + v
    end
    assert(sum ~= 0, "all weights are zero")
    local rnd = lrandom(sum)
    for k, v in pairs(t) do
        if rnd < v then return k end
        rnd = rnd - v
    end
end

local function generateLootTable()
    local loot_table = {}

    local armor_ids = EntityFactory.getIds('armor')
    for _, id in ipairs(armor_ids) do
        loot_table[id] = 2
    end

    local weapon_ids = EntityFactory.getIds('weapon')
    for _, id in ipairs(weapon_ids) do
        loot_table[id] = 2
    end

    return loot_table    
end

local function addLoot(level, level_idx, loot_table)
    local item_count = lrandom(5, 10)

    local level_w, level_h = level:getSize()

    while item_count > 0 do
        local item_id = weightedChoice(loot_table)
        -- TODO: why is item_id sometimes nil? maybe improve the weightedChoice algorithm?
        if item_id == nil then goto continue end

        local attempts = MAX_ATTEMPTS
        while attempts > 0 do
            attempts = attempts - 1

            local x = lrandom(1, level_w)
            local y = lrandom(1, level_h)
            local coord = vector(x, y)

            if not level:isBlocked(coord) then
                local item = EntityFactory.create(item_id, coord)
                print('add ' .. item.name .. ' at coord ' .. tostring(coord))
                level:addEntity(item)
                item_count = item_count - 1
                break
            end
        end

        ::continue::
    end
end

local function newLevel(dungeon, level_idx, loot_table)
    local level = Level(dungeon)
    addLoot(level, level_idx, loot_table)
    return level
end

Dungeon.new = function()
    local loot_table = generateLootTable()

    local player = EntityFactory.create('pc1')
    local levels, level_idx = {}, 0
    local alpha = 1.0

    local update = function(self, dt) levels[level_idx]:update(dt) end

    local draw = function(self)
        love.graphics.setColor(1.0, 1.0, 1.0, self.alpha) 
        levels[level_idx]:draw() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
    end

    local enter = function(self)
        level_idx = 1
        levels = { newLevel(self, level_idx, loot_table) }
        player.coord = levels[level_idx].entry_coord:clone()
        levels[level_idx]:enter(player)
    end

    local nextLevel = function(self)
        if level_idx == DUNGEON_LEVELS then 
            error('already at max level, should not have stairs down')
        end

        local control = player:getComponent(Control)
        control:setEnabled(false)

        Timer.tween(0.5, self, { alpha = 0.0 }, 'linear', function()
            levels[level_idx]:exit(player)
            -- proceed to next level, generating a new level if needed
            level_idx = level_idx + 1
            if level_idx > #levels then
                table.insert(levels, newLevel(self, level_idx, loot_table))
            end

            local level = levels[level_idx]
            player.coord = level.entry_coord:clone()
            level:enter(player)

            Timer.tween(0.5, self, { alpha = 1.0 }, 'linear', function()
                self.alpha = 1.0
                control:setEnabled(true)
            end)
        end)
    end

    local prevLevel = function(self)
        if level_idx == 1 then
            print('A magical force is preventing your exit. Maybe you need to find the Orb of Cerbos to escape?')
            return
        end

        local control = player:getComponent(Control)
        control:setEnabled(false)

        Timer.tween(0.5, self, { alpha = 0.0 }, 'linear', function()
            levels[level_idx]:exit(player)
            -- proceed to previous level
            level_idx = level_idx - 1
            local level = levels[level_idx]
            player.coord = level.exit_coord:clone()
            level:enter(player)

            Timer.tween(0.5, self, { alpha = 1.0 }, 'linear', function()
                self.alpha = 1.0
                control:setEnabled(true)
            end)
        end)
    end

    return setmetatable({
        -- properties
        alpha       = alpha,
        -- methods
        enter       = enter,
        update      = update,
        draw        = draw,
        nextLevel   = nextLevel,
        prevLevel   = prevLevel,
    }, Dungeon)
end

return setmetatable(Dungeon, { 
    __call = function(_, ...) return Dungeon.new(...) end,
})
