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
