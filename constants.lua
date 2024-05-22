--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

TILE_SIZE           = 48
MAP_SIZE            = 40

TURN_DURATION       = 0.2
ANIM_DURATION       = TURN_DURATION

-- base AP cost, the cost to perform most actions
ACTION_BASE_AP_COST = 30
-- a move factor used for diagonal movement for AP calculations
ORDINAL_MOVE_FACTOR = math.sqrt(2) 

WINDOW_W            = 800
WINDOW_H            = 450
UI_SCALE            = 1.0

STATUS_PANEL_W      = 48 * 3 -- equal to the size of 3 action buttons
ACTION_BAR_H        = 48

FONT = love.graphics.newImageFont('gfx/image_font.png', 
    '1234567890!#$%&*()-+=[]:;"\'<' ..
    '>,.?/abcdefghijklmnopqrstuvwx' ..
    'yz ABCDEFGHIJKLMNOPQRSTUVWXYZ')

FLAGS = TableHelper.readOnly({
    -- spell flags
    ['arcane']          = 0x1,
    ['divine']          = 0x2,

    -- effect flags
    ['projectile']      = 0x1,

    -- weapon flags
    ['natural_weapon']  = 0x1, -- weapons like claws, tooth, tail, fists, ...

    -- npc flags
    ['shadow_blend']    = 0x1, -- disappaer in shadows, but revealed by means of a Daylight spell
})
