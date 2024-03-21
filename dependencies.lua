--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Cache = require 'src.cache'

-- libraries
Camera          = require 'lib.hump.camera'
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
MapGenerator    = require 'src.generators.map_gen'
IdGenerator     = require 'src.generators.id_gen'
