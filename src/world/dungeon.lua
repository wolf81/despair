--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Dungeon = {}

Dungeon.new = function()
    local player = EntityFactory.create('pc1')
    local levels, level_idx = {}, 0

    local update = function(self, dt) levels[level_idx]:update(dt) end

    local draw = function(self) levels[level_idx]:draw() end

    local enter = function(self)
        levels = { Level(self) }
        level_idx = 1
        levels[level_idx]:enter(player)
    end

    local nextLevel = function(self)
        if level_idx == DUNGEON_LEVELS then 
            error('already at max level, should not have stairs down')
        end

        -- exit current level
        levels[level_idx]:exit(player)

        -- proceed to next level, generating a new level if needed
        level_idx = level_idx + 1
        if level_idx > #levels then
            local level = Level(self)
            table.insert(levels, level)
        end
        levels[level_idx]:enter(player)
    end

    local prevLevel = function(self)
        if level_idx == 1 then
            print('A magical force is preventing your exit. Maybe you need to find the Orb of Cerbos to escape?')
        end

        -- exit current level
        levels[level_idx]:exit(player)

        -- proceed to previous level
        level_idx = level_idx - 1
        levels[level_idx]:enter(player)
    end

    return setmetatable({
        -- methods
        enter   = enter,
        update  = update,
        draw    = draw,
    }, Dungeon)
end

return setmetatable(Dungeon, { 
    __call = function(_, ...) return Dungeon.new(...) end,
})
