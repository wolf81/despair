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
    local alpha = 1.0

    local update = function(self, dt) levels[level_idx]:update(dt) end

    local draw = function(self)
        love.graphics.setColor(1.0, 1.0, 1.0, self.alpha) 
        levels[level_idx]:draw() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
    end

    local enter = function(self)
        levels = { Level(self) }
        level_idx = 1
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
                table.insert(levels, Level(self))
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
