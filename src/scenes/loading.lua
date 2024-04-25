--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, mmax = math.floor, math.max

local MINIMUM_LOAD_DURATION = 0.5

local Loading = {}

local function registerQuadsByKey(key, size)
    local image = TextureCache:get(key)
    local quads = QuadGenerator.generate(image, size, size)
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

local function loadLevels()
    local levels_dir = 'gen/levels'
    local dir_path = love.filesystem.getRealDirectory(levels_dir)
    local files = love.filesystem.getDirectoryItems(levels_dir)
    local level_data = {}
    for _, file in ipairs(files) do
        local filepath = dir_path .. '/' .. levels_dir .. '/' .. file
        local getContents = assert(loadfile(filepath))
        table.insert(level_data, getContents())
    end

    -- sort by level index
    table.sort(level_data, function(a, b) return a.level < b.level end)

    return level_data
end

local function loadShaders()
    local shd_dir = 'shd'
    files = love.filesystem.getDirectoryItems(shd_dir)
    for _, file in ipairs(files) do
        if PathHelper.getExtension(file) ~= '.glsl' then goto continue end 

        local key = PathHelper.getFilename(file)
        local shader = love.graphics.newShader(shd_dir .. '/' .. file)
        ShaderCache:register(key, shader)

        ::continue::
    end
end

local function loadEntities()
    local data_dir = 'gen'
    local dirs = love.filesystem.getDirectoryItems(data_dir)
    for _, dir in ipairs(dirs) do
        -- by convention, all /entity/ directory names end in 'defs' 
        if StringHelper.endsWith(dir, 'defs') then
            EntityFactory.register(data_dir .. '/' .. dir)
        end
    end
end

local function loadGraphics()
    local gfx_dir = 'gfx'
    files = love.filesystem.getDirectoryItems(gfx_dir)
    for _, file in ipairs(files) do
        if PathHelper.getExtension(file) ~= '.png' then goto continue end 

        local key = PathHelper.getFilename(file)

        local image = love.graphics.newImage(gfx_dir .. '/' .. file)
        image:setFilter('nearest', 'nearest')
        TextureCache:register(key, image)

        ::continue::
    end
end

local function registerQuads()
    for _, key in ipairs({ 'uf_terrain', 'uf_heroes', 'uf_items', 'uf_fx_impact', 'actionbar' }) do
        registerQuadsByKey(key, 48)
    end

    for _, key in ipairs({ 'uf_fx', 'projectiles' }) do
        registerQuadsByKey(key, 24)
    end

    registerQuadsByKey('uf_portraits', 50)

    registerSkillsQuads()
    registerInterfaceQuads()
    registerProjectilesQuads()
end

Loading.new = function()
    local background = love.graphics.newImage('gfx/loading.png')
    local background_w, background_h = background:getDimensions()

    local text = 'LOADING'
    local text_h = FONT:getHeight()
    local text_x = mfloor((WINDOW_W - FONT:getWidth(text)) / 2)
    local text_y = mfloor((WINDOW_H - FONT:getHeight()) / 2)

    local time = MINIMUM_LOAD_DURATION

    local level_info = nil

    local onLoadLevels = function(level_info_) level_info = level_info_ end

    -- load assets in this order and show appropriate message
    local loaders = {
        { Loader(loadGraphics),             'load graphics'     },
        { Loader(registerQuads),            'register quads'    },
        -- TODO: cleaner if we can load health bar as part of graphics, but needs to know quads
        { Loader(HealthBar.preload),        'load health bar'   }, 
        { Loader(loadShaders),              'load shaders'      },
        { Loader(loadEntities),             'load entities'     },
        { Loader(loadLevels, onLoadLevels), 'load levels'       },
    }

    local loader, message, message_x = nil, nil, 0

    local enter = function(self)
        loader, message = unpack(table.remove(loaders, 1))
        message_x = mfloor((WINDOW_W - FONT:getWidth(message)) / 2)
    end

    local update = function(self, dt)
        time = mmax(time - dt, 0)

        local is_done = loader:update()
        if is_done and #loaders > 0 then
            loader, message = unpack(table.remove(loaders, 1))
            message_x = mfloor((WINDOW_W - FONT:getWidth(message)) / 2)
        elseif is_done and #loaders == 0 and time == 0 then
            Gamestate.switch(Game(level_info))            
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
        -- methods
        draw        = draw,
        enter       = enter,
        update      = update,
        keyreleased = keyReleased,
    }, Loading)
end

return setmetatable(Loading, {
    __call = function(_, ...) return Loading.new(...) end,
})
