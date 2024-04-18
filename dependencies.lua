--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Cache = require 'src.util.cache'

-- libraries
bresenham           = require 'lib.bresenham.bresenham'
Gamestate           = require 'lib.hump.gamestate'
Signal              = require 'lib.hump.signal'
vector              = require 'lib.hump.vector'
Timer               = require 'lib.hump.timer'
lume                = require 'lib.lume.lume'
tidy                = require 'lib.composer' -- TODO: rename composer to tidy
ndn                 = require 'lib.ndn'

-- helpers
ActionHelper        = require 'src.helpers.action_helper'
StringHelper        = require 'src.helpers.string_helper'
ColorHelper         = require 'src.helpers.color_helper'
TableHelper         = require 'src.helpers.table_helper'
PathHelper          = require 'src.helpers.path_helper'

-- scenes
ChooseItem          = require 'src.scenes.choose_item'
CharSheet           = require 'src.scenes.char_sheet'
Inventory           = require 'src.scenes.inventory'
Loading             = require 'src.scenes.loading'
Game                = require 'src.scenes.game'

-- world
Dungeon             = require 'src.world.dungeon'
Level               = require 'src.world.level'
Map                 = require 'src.world.map'

-- ui
ActionButton        = require 'src.ui.action_button'
ResourceBar         = require 'src.ui.resource_bar'
ImageButton         = require 'src.ui.image_button'
StatusPanel         = require 'src.ui.status_panel'
FlexPanel           = require 'src.ui.flex_panel'
FlexSpace           = require 'src.ui.flex_space'
Overlay             = require 'src.ui.overlay'
Label               = require 'src.ui.label'

-- util
Shadowcaster        = require 'src.util.shadowcaster'
Direction           = require 'src.util.direction'
Animation           = require 'src.util.animation'
Scheduler           = require 'src.util.scheduler'
Camera              = require 'src.util.camera'
Chart               = require 'src.util.chart'
Rect                = require 'src.util.rect'
Turn                = require 'src.util.turn'
Fog                 = require 'src.util.fog'
UI                  = require 'src.util.ui'

-- dijkstra
DijkstraMap         = require 'src.dijkstra.dijkstra'

-- actions
Destroy             = require 'src.actions.destroy'
Attack              = require 'src.actions.attack'
Move                = require 'src.actions.move'
Idle                = require 'src.actions.idle'

-- input modes
Keyboard            = require 'src.input_modes.keyboard'
Mouse               = require 'src.input_modes.mouse'
Cpu                 = require 'src.input_modes.cpu'

-- entity component system
EntityFactory       = require 'src.ecs.factory'
Entity              = require 'src.ecs.entity'
System              = require 'src.ecs.system'

-- components
Cartographer        = require 'src.components.cartographer'
Equippable          = require 'src.components.equippable'
HealthBar           = require 'src.components.health_bar'
MoveSpeed           = require 'src.components.move_speed'
Equipment           = require 'src.components.equipment'
ExpLevel            = require 'src.components.exp_level'
Backpack            = require 'src.components.backpack'
Control             = require 'src.components.control'
Offense             = require 'src.components.offense'
Defense             = require 'src.components.defense'
Usable              = require 'src.components.usable'
Energy              = require 'src.components.energy'
Visual              = require 'src.components.visual'
Health              = require 'src.components.health'
Skills              = require 'src.components.skills'
Stats               = require 'src.components.stats'
Item                = require 'src.components.item'
Info                = require 'src.components.info'

-- resolvers
CombatResolver      = require 'src.resolvers.combat'

-- caches
TextureCache        = Cache()
ShaderCache         = Cache()
QuadCache           = Cache()

-- generators
FontSheetGenerator  = require 'src.generators.font_sheet_gen'
QuadSheetGenerator  = require 'src.generators.quad_sheet_gen'
PortraitGenerator   = require 'src.generators.portrait_gen'
TextureGenerator    = require 'src.generators.texture_gen'
QuadGenerator       = require 'src.generators.quad_gen'
MazeGenerator       = require 'src.generators.maze_gen'
IdGenerator         = require 'src.generators.id_gen'
