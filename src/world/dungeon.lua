--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Dungeon = {}

Dungeon.new = function()
    -- TODO: add new level when user navigates to next level
    local levels = { Level() }
    local level_idx = 1

    local update = function(self, dt) levels[level_idx]:update(dt) end

    local draw = function(self) levels[level_idx]:draw() end

    return setmetatable({
        -- methods
        update  = update,
        draw    = draw,
    }, Dungeon)
end

return setmetatable(Dungeon, { 
    __call = function(_, ...) return Dungeon.new(...) end,
})
