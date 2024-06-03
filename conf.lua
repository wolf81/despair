--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

require 'constants'

function love.conf(t)
    t.window.title = 'Dungeon of Despair'
    t.window.width = WINDOW_W * UI_SCALE    -- The window width (number)
    t.window.height = WINDOW_H * UI_SCALE   -- The window height (number)
    t.window.highdpi = false                -- Enable high-dpi mode for retina display (boolean)
end