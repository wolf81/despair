--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Game = {}

Game.new = function()
    love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc1')
    local player_info = PlayerInfo(player)

    local dungeon = Dungeon(player)
    dungeon:enter()

    local is_paused = false

    local portrait = Portrait()

    local update = function(self, dt) 
        if not is_paused then
            dungeon:update(dt) 
        end
    end

    local draw = function(self) 
        dungeon:draw(0, 0, WINDOW_W - 160, WINDOW_H) 

        love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
        love.graphics.rectangle('fill', WINDOW_W - 160, 0, 160, WINDOW_H)

        player_info:draw(WINDOW_W - 160, 0, 160, WINDOW_H)
    end

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
