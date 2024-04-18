--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

TILE_SIZE           = 48
MAP_SIZE            = 40
DUNGEON_LEVELS      = 40
SCALE               = 1.0
TURN_DURATION       = 0.2
ANIM_DURATION       = TURN_DURATION
ORDINAL_MOVE_FACTOR = 1.4 -- ~math.sqrt(2)

ACTION_BASE_AP_COST = 30

WINDOW_W            = 800
WINDOW_H            = 450

STATUS_PANEL_W        = 48 * 3
ACTION_BAR_H        = 50

CLASSES = TableHelper.readOnly({
    ['fighter']     = true,
    ['cleric']      = true,
    ['rogue']       = true,
    ['mage']        = true,
})

RACES = TableHelper.readOnly({
    ['halfling']    = true,
    ['human']       = true,
    ['dwarf']       = true,
    ['elf']         = true,
})

FONT = love.graphics.newImageFont('gfx/image_font.png', 
    "1234567890!#$%&*()-+=[]:;\"'<" ..
    ">,.?/abcdefghijklmnopqrstuvwx" ..
    "yz ABCDEFGHIJKLMNOPQRSTUVWXYZ")
