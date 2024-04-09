--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Cache = require 'src.util.cache'

-- libraries
bresenham           = require 'lib.bresenham.bresenham'
Signal              = require 'lib.hump.signal'
vector              = require 'lib.hump.vector'
Timer               = require 'lib.hump.timer'
lume                = require 'lib.lume.lume'
ndn                 = require 'lib.ndn'

-- scenes
Game                = require 'src.scenes.game'

-- world
Dungeon             = require 'src.world.dungeon'
Level               = require 'src.world.level'
Map                 = require 'src.world.map'

-- hud
ResourceBar         = require 'src.hud.resource_bar'
PlayerInfo          = require 'src.hud.player_info'
Inventory           = require 'src.hud.inventory'
Portrait            = require 'src.hud.portrait'
Minimap             = require 'src.hud.minimap'

-- helpers
ActionHelper        = require 'src.helpers.action_helper'
ColorHelper         = require 'src.helpers.color_helper'

-- util
Shadowcaster        = require 'src.util.shadowcaster'
Direction           = require 'src.util.direction'
Animation           = require 'src.util.animation'
Scheduler           = require 'src.util.scheduler'
Pointer             = require 'src.util.pointer'
Camera              = require 'src.util.camera'
Turn                = require 'src.util.turn'
Fog                 = require 'src.util.fog'

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
HealthBar           = require 'src.components.health_bar'
MoveSpeed           = require 'src.components.move_speed'
Equipment           = require 'src.components.equipment'
ExpLevel            = require 'src.components.exp_level'
Backpack            = require 'src.components.backpack'
Control             = require 'src.components.control'
Offense             = require 'src.components.offense'
Defense             = require 'src.components.defense'
Energy              = require 'src.components.energy'
Visual              = require 'src.components.visual'
Health              = require 'src.components.health'
Skills              = require 'src.components.skills'
Stats               = require 'src.components.stats'
Item                = require 'src.components.item'

-- resolvers
CombatResolver      = require 'src.resolvers.combat'

-- caches
TextureCache        = Cache()
ShaderCache         = Cache()
QuadCache           = Cache()

-- generators
FontSheetGenerator  = require 'src.generators.font_sheet_gen'
QuadSheetGenerator  = require 'src.generators.quad_sheet_gen'
TextureGenerator    = require 'src.generators.texture_gen'
QuadGenerator       = require 'src.generators.quad_gen'
MazeGenerator       = require 'src.generators.maze_gen'
IdGenerator         = require 'src.generators.id_gen'
