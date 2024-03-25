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
        levels[level_idx]:enter(player, Stair.UP)
    end

    local nextLevel = function(self)
        if level_idx == DUNGEON_LEVELS then 
            error('already at max level, should not have stairs down')
        end

        -- exit current level
        levels[level_idx]:exit(player)

        -- FIXME: seems we need to add a delay, due to some global camera state causing camera to 
        -- target wrong area in map
        Timer.after(0.5, function() 
            -- proceed to next level, generating a new level if needed
            level_idx = level_idx + 1
            if level_idx > #levels then
                local level = Level(self)
                table.insert(levels, level)
            end
            levels[level_idx]:enter(player, Stair.UP)
        end)
    end

    local prevLevel = function(self)
        if level_idx == 1 then
            print('A magical force is preventing your exit. Maybe you need to find the Orb of Cerbos to escape?')
            return
        end

        -- exit current level
        levels[level_idx]:exit(player)

        -- FIXME: seems we need to add a delay, due to some global camera state causing camera to 
        -- target wrong area in map
        Timer.after(0.5, function() 
            -- proceed to previous level
            level_idx = level_idx - 1
            levels[level_idx]:enter(player, Stair.DOWN)
        end)
    end

    return setmetatable({
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
