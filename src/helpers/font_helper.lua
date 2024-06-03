--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local M = {}

local font = nil

M.setDefaultFont = function()
    font = love.graphics.newImageFont('gfx/image_font.png', 
        '1234567890!#$%&*()-+=[]:;"\'<' ..
        '>,.?/abcdefghijklmnopqrstuvwx' ..
        'yz ABCDEFGHIJKLMNOPQRSTUVWXYZ')    
    font:setLineHeight(2.0)
    love.graphics.setFont(font)
end

M.getDefaultFont = function()
    assert(font ~= nil, 'font not configured, call "configure()" prior to use')
    return font
end

return M
