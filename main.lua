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

local function registerTerrainQuads()
    local key = 'uf_terrain'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 48, 48)
    QuadCache:register(key, quads)
end

local function registerItemsQuads()
    local key = 'uf_items'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 48, 48)
    QuadCache:register(key, quads)
end

local function registerHeroesQuads()
    local key = 'uf_heroes'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 48, 48)
    QuadCache:register(key, quads)
end

local function registerFxQuads()
    local key = 'uf_fx'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 24, 24)
    QuadCache:register(key, quads)
end

local function registerFxImpactQuads()
    local key = 'uf_fx_impact'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 48, 48)
    QuadCache:register(key, quads)
end

local function registerProjectilesQuads()
    local key = 'projectiles'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 24, 24)
    QuadCache:register(key, quads)
end

local function registerInterfaceQuads()
    local key = 'uf_interface'
    local image = TextureCache:get(key)
    local image_w, image_h = image:getDimensions()

    local quads = {}

    for _, quad in ipairs(QuadGenerator.generate(image, 8, 8, 584, 8, 264, 30)) do
        table.insert(quads, quad)
    end

    for _, quad in ipairs(QuadGenerator.generate(image, 24, 24, 584, 64)) do
        table.insert(quads, quad)
    end

    for _, quad in ipairs(QuadGenerator.generate(image, 28, 5, 481, 29, 28, 60)) do
        table.insert(quads, quad)
    end

    for _, quad in ipairs(QuadGenerator.generate(image, 16, 16, 480, 256, 96, 144)) do
        table.insert(quads, quad)
    end

    -- UI: gray, blue, brown
    for _, x in ipairs({ 8, 168, 328 }) do

        -- health, mana, energy bars
        for _, y in ipairs({ 10, 26 }) do
            for _, quad in ipairs(QuadGenerator.generate(image, 48, 12, x, y, 96, 12)) do
                table.insert(quads, quad)
            end
        end

        -- panels
        for y = 56, 136, 16 do
            for _, quad in ipairs(QuadGenerator.generate(image, 16, 16, x, y, 48, 16)) do
                table.insert(quads, quad)
            end

            for _, quad in ipairs(QuadGenerator.generate(image, 8, 16, x + 48, y, 8, 16)) do
                table.insert(quads, quad)
            end

            for _, quad in ipairs(QuadGenerator.generate(image, 16, 16, x + 56, y, 16, 16)) do
                table.insert(quads, quad)
            end
        end

    end

    QuadCache:register(key, quads)
end

local function registerSkillsQuads()
    local key = 'uf_skills'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 24, 24, 584, 64)
    QuadCache:register(key, quads)
end

local function registerPortraitsQuads()
    local key = 'uf_portraits'
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, 50, 50)
    QuadCache:register(key, quads)
end

local function registerQuads()
    registerHeroesQuads()
    registerFxQuads()
    registerFxImpactQuads()
    registerInterfaceQuads()
    registerTerrainQuads()
    registerItemsQuads()
    registerPortraitsQuads()
    registerSkillsQuads()
    registerProjectilesQuads()
end

local function preload()
    -- register entities with entity factory
    local data_dir = 'gen'
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

        ::continue::
    end

    registerQuads()

    local shd_dir = 'shd'
    local files = love.filesystem.getDirectoryItems(shd_dir)
    for _, file in ipairs(files) do
        if getExtension(file) ~= '.glsl' then goto continue end 

        local key = getFilename(file)

        local shader = love.graphics.newShader(shd_dir .. '/' .. file)
        ShaderCache:register(key, shader)

        ::continue::
    end

    HealthBar.preload()
end

function love.load(args)
    love.window.setTitle('Dungeon of Despair')

    preload()

    -- init graphics for pointer device
    Pointer.init()

    success = love.window.setMode(WINDOW_W * SCALE, WINDOW_H * SCALE, {
        highdpi = false,
    })

    for _, arg in ipairs(args) do
        if arg == '--quadsheet' then
            QuadSheetGenerator.generate()
            love.event.quit()
        elseif arg == '--imagefont' then
            FontSheetGenerator.generate()            
            love.event.quit()
        end
    end
    love.graphics.scale(SCALE)

    local game = Game()

    Gamestate.registerEvents()
    Gamestate.switch(game)

    -- game = Game()
end

function love.update(dt)
    Timer.update(dt)
    -- game:update(dt)
end

function love.draw()

    -- game:draw()
end
