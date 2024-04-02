--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

io.stdout:setvbuf('no')

require 'dependencies'
require 'constants'

local function getExtension(path)
  return path:match("^.+(%..+)$")
end

local function getFilename(path)
    return path:match('^(.*)%.')
end

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
        if getExtension(file) ~= '.png' then goto continue end 

        local key = getFilename(file)

        local image = love.graphics.newImage(gfx_dir .. '/' .. file)
        image:setFilter('nearest', 'nearest')
        TextureCache:register(key, image)

        -- TODO: ugly to adjust size here for single texture - maybe should configure in data file 
        -- instead, as part of entities & load later ...
        local size = key == 'uf_fx' and (TILE_SIZE / 2) or TILE_SIZE 

        local quads = QuadGenerator.generate(image, size, size)
        QuadCache:register(key, quads)

        ::continue::
    end

    local shd_dir = 'shd'
    local files = love.filesystem.getDirectoryItems(shd_dir)
    for _, file in ipairs(files) do
        if getExtension(file) ~= '.glsl' then goto continue end 

        local key = getFilename(file)

        local shader = love.graphics.newShader(shd_dir .. '/' .. file)
        ShaderCache:register(key, shader)

        ::continue::
    end
end

function love.load(args)
    preload()

    -- init graphics for pointer device
    Pointer.init()

    success = love.window.setMode(WINDOW_W * SCALE, WINDOW_H * SCALE, {
        highdpi = false,
    })

    for _, arg in ipairs(args) do
        if arg == '--quadsheet' then
            for key, image in TextureCache:each() do
                local w, h = image:getDimensions()

                local canvas = love.graphics.newCanvas(w, h)
                canvas:renderTo(function() 
                    love.graphics.draw(image, 0, 0)

                    local quads = QuadCache:get(key)
                    love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
                    for idx, quad in ipairs(quads) do
                        local x, y, w, h = quad:getViewport()
                        love.graphics.rectangle('line', x, y, w, h)
                        love.graphics.print(idx, x + 2, y + 2)
                    end
                    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
                end)

                local image_data = canvas:newImageData()
                image_data:encode('png', key .. '.png')
            end

            love.event.quit()
        end
    end

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
