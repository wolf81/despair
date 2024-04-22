--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

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

    for _, id in ipairs(EntityFactory.getIds('armor')) do
        loot_table[id] = 2
    end

    for _, id in ipairs(EntityFactory.getIds('weapon')) do
        -- TODO: should have 'natural weapon' flag for items that should not be loot
        if id ~= 'bite' and id ~= 'unarmed' then
            loot_table[id] = 2
        end
    end

    for _, id in ipairs(EntityFactory.getIds('ring')) do
        loot_table[id] = 2
    end

    for _, id in ipairs(EntityFactory.getIds('potion')) do
        loot_table[id] = 2
    end

    for _, id in ipairs(EntityFactory.getIds('necklace')) do
        loot_table[id] = 2
    end

    for _, id in ipairs(EntityFactory.getIds('tome')) do
        loot_table[id] = 2
    end

    for _, id in ipairs(EntityFactory.getIds('wand')) do
        loot_table[id] = 2
    end

    for _, id in ipairs(EntityFactory.getIds('food')) do
        loot_table[id] = 14
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

            if not level:isBlocked(coord) and not level:hasStairs(coord) then 
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
    local level = Level(dungeon, level_idx)
    addLoot(level, level_idx, loot_table)
    return level
end

Dungeon.new = function(player)
    assert(player ~= nil, 'missing argument: "player"')
    
    local loot_table = generateLootTable()

    local levels, level_idx = {}, 0
    local alpha = 1.0

    local frame = Rect(0)

    local update = function(self, dt) levels[level_idx]:update(dt) end

    local draw = function(self)
        love.graphics.setColor(1.0, 1.0, 1.0, self.alpha) 
        levels[level_idx]:draw(frame:unpack()) 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
    end

    local enter = function(self)
        level_idx = 1
        levels = { newLevel(self, level_idx, loot_table) }
        levels[level_idx]:enter(player)
    end

    local nextLevel = function(self)
        if level_idx == DUNGEON_LEVELS then 
            error('already at max level, should not have stairs down')
        end

        Signal.emit('change-level', player, level_idx + 1)
    end

    local prevLevel = function(self)
        if level_idx == 1 then
            print('A magical force is preventing your exit. Maybe you need to find the Orb of Cerbos to escape?')
            return
        end

        Signal.emit('change-level', player, level_idx - 1)
    end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getLevel = function(self, idx) return levels[level_idx] end

    local setLevel = function(self, level_idx_)
        local direction = level_idx_ < level_idx and 'up' or 'down'

        levels[level_idx]:exit(player)

        level_idx = level_idx_        
        if level_idx > #levels then
            table.insert(levels, newLevel(self, level_idx, loot_table))
        end
        levels[level_idx]:enter(player, direction)
    end

    return setmetatable({
        -- properties
        alpha           = alpha,
        -- methods
        draw            = draw,
        enter           = enter,
        update          = update,
        setFrame        = setFrame,
        getLevel        = getLevel,
        setLevel        = setLevel,
        -- TODO: call these methods from Level directly?
        nextLevel       = nextLevel,
        prevLevel       = prevLevel,
    }, Dungeon)
end

return setmetatable(Dungeon, { 
    __call = function(_, ...) return Dungeon.new(...) end,
})
