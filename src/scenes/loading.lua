--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local MINIMUM_LOAD_DURATION = 0.2

local Loading = {}

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

-- will return a thread that can be started to load resources asynchronously
local function newPreloader()
    local preloader = coroutine.create(function()
        coroutine.yield('loading entities')

        -- register entities with entity factory
        local data_dir = 'gen'
        local dirs = love.filesystem.getDirectoryItems(data_dir)
        for _, dir in ipairs(dirs) do
            EntityFactory.register(data_dir .. '/' .. dir)
        end
            
        -- generate textures & quads
        -- cache generated textures & quads
        coroutine.yield('loading textures')
        local gfx_dir = 'gfx'
        local files = love.filesystem.getDirectoryItems(gfx_dir)
        for _, file in ipairs(files) do
            if PathHelper.getExtension(file) ~= '.png' then goto continue end 

            local key = PathHelper.getFilename(file)

            local image = love.graphics.newImage(gfx_dir .. '/' .. file)
            image:setFilter('nearest', 'nearest')
            TextureCache:register(key, image)

            ::continue::
        end

        coroutine.yield('generate quads')
        registerQuads()

        coroutine.yield('load shaders')
        local shd_dir = 'shd'
        local files = love.filesystem.getDirectoryItems(shd_dir)
        for _, file in ipairs(files) do
            if PathHelper.getExtension(file) ~= '.glsl' then goto continue end 

            local key = PathHelper.getFilename(file)
            local shader = love.graphics.newShader(shd_dir .. '/' .. file)
            ShaderCache:register(key, shader)

            ::continue::
        end

        coroutine.yield('generate healthbar textures')
        HealthBar.preload()
    end)

    return preloader
end

Loading.new = function()
    local background = love.graphics.newImage('gfx/loading.png')
    local background_w, background_h = background:getDimensions()

    local text = "LOADING"
    local text_h = FONT:getHeight()
    local text_x = mfloor((WINDOW_W - FONT:getWidth(text)) / 2)
    local text_y = mfloor((WINDOW_H - FONT:getHeight()) / 2)

    local time = MINIMUM_LOAD_DURATION

    local preloader = newPreloader()

    local message, message_x = nil

    local enter = function(self)
        coroutine.resume(preloader)
    end

    local update = function(self, dt)
        time = math.max(time - dt, 0)

        local preloader_status = coroutine.status(preloader)

        if preloader_status == 'suspended' then 
            local status, msg = coroutine.resume(preloader)
            message = msg or 'done'
            message_x = mfloor((WINDOW_W - FONT:getWidth(message)) / 2)
        elseif preloader_status == 'dead' and time == 0 then
            Gamestate.switch(Game())
        end
    end

    local draw = function(self)
        love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
        love.graphics.rectangle('fill', 0, 0, WINDOW_W, WINDOW_H)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, 
            mfloor((WINDOW_W - background_w) / 2), 
            mfloor((WINDOW_H - background_h) / 2))

        love.graphics.print(text, text_x, text_y - 20)

        love.graphics.print(message, message_x, text_y + 20)
    end

    local keyReleased = function(self, key, scancode)        
        if Gamestate.current() == self and key == "escape" then
            love.event.quit()
        end
    end

    return setmetatable({
        keyreleased = keyReleased,
        update      = update,
        enter       = enter,
        draw        = draw,
    }, Loading)
end

return setmetatable(Loading, {
    __call = function(_, ...) return Loading.new(...) end,
})
