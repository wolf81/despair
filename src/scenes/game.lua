--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Game = {}

Game.new = function()
    love.math.setRandomSeed(1)

    local dungeon = Dungeon()
    dungeon:enter()

    local is_paused = false

    local update = function(self, dt) 
        if not is_paused then
            dungeon:update(dt) 
        end
    end

    local draw = function(self) dungeon:draw() end

    local togglePaused = function(self) is_paused = (not is_paused) end

    return setmetatable({
        -- methods
        update          = update,
        draw            = draw,
        togglePaused    = togglePaused,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
