--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

TILE_SIZE           = 48
MAP_SIZE            = 4
DUNGEON_LEVELS      = 40
SCALE               = 1.0
TURN_DURATION       = 0.2
TURN_DELAY          = 3.0
GAME_SPEED          = 4.0
ANIM_DURATION       = TURN_DURATION

ACTION_BASE_AP_COST = 30

WINDOW_W            = 640
WINDOW_H            = 480

CLASSES = {
    ['fighter']     = true,
    ['cleric']      = true,
    ['rogue']       = true,
    ['mage']        = true,
}

RACES = {
    ['halfling']    = true,
    ['human']       = true,
    ['dwarf']       = true,
    ['elf']         = true,
}

FONT_CHARS = "1234567890!#$%&*()-+=[]:;\"'<>,.?/abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ"

FONT = love.graphics.newImageFont('gfx/image_font.png', FONT_CHARS)