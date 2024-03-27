--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Cache = require 'src.util.cache'

-- libraries
Camera          = require 'lib.hump.camera'
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
Turn            = require 'src.util.turn'
Fog             = require 'src.util.fog'

-- actions
Destroy         = require 'src.actions.destroy'
Attack          = require 'src.actions.attack'
Move            = require 'src.actions.move'
Idle            = require 'src.actions.idle'

-- input modes
Keyboard        = require 'src.input_modes.keyboard'
Cpu             = require 'src.input_modes.cpu'

-- entity component system
EntityFactory   = require 'src.ecs.factory'
Entity          = require 'src.ecs.entity'
System          = require 'src.ecs.system'

-- components
Equipment       = require 'src.components.equipment'
ExpLevel        = require 'src.components.exp_level'
Control         = require 'src.components.control'
Visual          = require 'src.components.visual'
Health          = require 'src.components.health'
Weapon          = require 'src.components.weapon'
Armor           = require 'src.components.armor'
Stats           = require 'src.components.stats'

-- resolvers
MeleeCombat     = require 'src.resolvers.melee_combat'

-- caches
TextureCache    = Cache()
ShaderCache     = Cache()
QuadCache       = Cache()

-- generators
QuadGenerator   = require 'src.generators.quad_gen'
MazeGenerator   = require 'src.generators.maze_gen'
IdGenerator     = require 'src.generators.id_gen'
