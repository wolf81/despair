--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

io.stdout:setvbuf('no')

require 'dependencies'
require 'constants'

local function preload()
    -- register entities with entity factory
    local data_dir = 'dat/gen'
    local dirs = love.filesystem.getDirectoryItems(data_dir)
    for _, dir in ipairs(dirs) do
        EntityFactory.register(data_dir .. '/' .. dir)
    end
        
    -- generate textures & quads
    -- cache generated textures & quads
    local gfx_dir = 'gfx'
    local files = love.filesystem.getDirectoryItems(gfx_dir)
    for _, file in ipairs(files) do
        local key = file:match('^(.*)%.')

        local image = love.graphics.newImage(gfx_dir .. '/' .. file)
        image:setFilter('nearest', 'nearest')
        TextureCache:register(key, image)

        -- TODO: ugly to adjust size here for single texture - maybe should configure in data file 
        -- instead, as part of entities & load later ...
        local size = key == 'uf_fx' and (TILE_SIZE / 2) or TILE_SIZE 

        local quads = QuadGenerator.generate(image, size, size)
        QuadCache:register(key, quads)
    end

    local shd_dir = 'shd'
    local files = love.filesystem.getDirectoryItems(shd_dir)
    for _, file in ipairs(files) do
        local key = file:match('^(.*)%.')

        local shader = love.graphics.newShader(shd_dir .. '/' .. file)
        ShaderCache:register(key, shader)
        print('shader', key)
    end
end

function love.load(args)
    preload()

    success = love.window.setMode(WINDOW_W * SCALE, WINDOW_H * SCALE, {
        highdpi = false,
    })

    game = Game()
end

function love.update(dt)
    Timer.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
end
