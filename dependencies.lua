--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Cache = require 'src.util.cache'

-- libraries
bresenham       = require 'lib.bresenham.bresenham'
Signal          = require 'lib.hump.signal'
vector          = require 'lib.hump.vector'
Timer           = require 'lib.hump.timer'
lume            = require 'lib.lume.lume'
ndn             = require 'lib.ndn'

-- scenes
Game            = require 'src.scenes.game'

-- world
Dungeon         = require 'src.world.dungeon'
Level           = require 'src.world.level'
Map             = require 'src.world.map'

-- util
Shadowcaster    = require 'src.util.shadowcaster'
Direction       = require 'src.util.direction'
Animation       = require 'src.util.animation'
Pointer         = require 'src.util.pointer'
Camera          = require 'src.util.camera'
Fog             = require 'src.util.fog'

-- actions
Destroy         = require 'src.actions.destroy'
Attack          = require 'src.actions.attack'
Move            = require 'src.actions.move'
Idle            = require 'src.actions.idle'

-- input modes
Keyboard        = require 'src.input_modes.keyboard'
Mouse           = require 'src.input_modes.mouse'
Cpu             = require 'src.input_modes.cpu'

-- entity component system
EntityFactory   = require 'src.ecs.factory'
Entity          = require 'src.ecs.entity'
System          = require 'src.ecs.system'

-- components
MoveSpeed       = require 'src.components.move_speed'
Equipment       = require 'src.components.equipment'
ExpLevel        = require 'src.components.exp_level'
Backpack        = require 'src.components.backpack'
Control         = require 'src.components.control'
Visual          = require 'src.components.visual'
Health          = require 'src.components.health'
Weapon          = require 'src.components.weapon'
Skills          = require 'src.components.skills'
Stats           = require 'src.components.stats'
Armor           = require 'src.components.armor'

-- resolvers
CombatResolver  = require 'src.resolvers.combat'

-- caches
TextureCache    = Cache()
ShaderCache     = Cache()
QuadCache       = Cache()

-- generators
QuadGenerator   = require 'src.generators.quad_gen'
MazeGenerator   = require 'src.generators.maze_gen'
IdGenerator     = require 'src.generators.id_gen'
