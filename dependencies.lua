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

-- scenes
Game            = require 'src.scenes.game'

-- world
Dungeon         = require 'src.world.dungeon'
Level           = require 'src.world.level'
Map             = require 'src.world.map'

Turn            = require 'src.turn'

-- util
Direction       = require 'src.util.direction'
Animation       = require 'src.util.animation'

-- actions
Move            = require 'src.actions.move'

-- input types
Keyboard        = require 'src.input_types.keyboard'
Cpu             = require 'src.input_types.cpu'

-- entity component system
EntityFactory   = require 'src.ecs.factory'
Entity          = require 'src.ecs.entity'
System          = require 'src.ecs.system'

-- components
Visual          = require 'src.components.visual'
Control         = require 'src.components.control'

-- caches
TextureCache    = Cache()
QuadCache       = Cache()

-- generators
QuadGenerator   = require 'src.generators.quad_gen'
MazeGenerator   = require 'src.generators.maze_gen'
IdGenerator     = require 'src.generators.id_gen'
