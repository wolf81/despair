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

-- util
Direction       = require 'src.util.direction'
Animation       = require 'src.util.animation'

-- entity manager
EntityManager   = require 'src.entity_manager'

-- entity component system
EntityFactory   = require 'src.ecs.factory'
Entity          = require 'src.ecs.entity'
System          = require 'src.ecs.system'

-- components
Intellect       = require 'src.components.intellect'
Visual          = require 'src.components.visual'
Input           = require 'src.components.input'

-- caches
TextureCache    = Cache()
QuadCache       = Cache()

-- generators
QuadGenerator   = require 'src.generators.quad_gen'
MazeGenerator   = require 'src.generators.maze_gen'
IdGenerator     = require 'src.generators.id_gen'
