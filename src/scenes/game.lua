--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Game = {}

Game.new = function()
    -- love.math.setRandomSeed(1)

    local player = EntityFactory.create('pc3')
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

    local player_info_w = INFO_PANEL_WIDTH

    local draw = function(self) 
        love.graphics.push()
        love.graphics.scale(SCALE)

        dungeon:draw(0, 0, WINDOW_W - player_info_w, WINDOW_H) 

        love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
        love.graphics.rectangle('fill', WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        player_info:draw(WINDOW_W - player_info_w, 0, player_info_w, WINDOW_H)

        if is_paused then
            love.graphics.setFont(FONT)

            local text_w = FONT:getWidth('PAUSED')
            local text_x = 25
            local text_y = WINDOW_H - 30
            local text_h = FONT:getHeight()

            love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
            love.graphics.rectangle('fill', text_x - 5, text_y - 5, text_w + 10, text_h + 5 * 2)
 
            love.graphics.setLineWidth(1.0)
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            love.graphics.rectangle('line', text_x - 5.5, text_y - 5.5, text_w + 10, text_h + 5 * 2)

            love.graphics.printf('PAUSED', text_x, text_y, text_w, 'left')
        end

        love.graphics.pop()
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
