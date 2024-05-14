--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, mmax = math.floor, math.max

local Loading = {}

local MINIMUM_LOAD_DURATION = 0.1

local ASSETS = {
    ['uf_skills'] = {
        { 24, 24 },
    },
    ['uf_fx'] = {
        { 24, 24 },
    },
    ['projectiles'] = {
        { 24, 24 },
    },
    ['uf_terrain'] = {
        { 48, 48 }, 
    },
    ['uf_heroes'] = {
        { 48, 48 }, 
    },
    ['uf_items'] = {
        { 48, 48 }, 
    },
    ['uf_fx_impact'] = {
        { 48, 48 }, 
    },
    ['actionbar'] = {
        { 48, 48 }, 
    },
    ['uf_portraits'] = {
        { 50, 50 },
    },
    ['border'] = {
        { 16, 16,  0, 0, 48, 32 },
        { 16, 16, 56, 0         },
    },
    ['uf_interface'] = {
        {  8,   8, 584,   8, 264,  30 },
        { 24,  24, 584,  64           },
        { 28,   5, 481,  29,  28,  60 },
        { 16,  16, 480, 256,  96, 144 },
        -- health, mana & energy bars
        { 48,  12,   8,  10,  96,  12 },
        { 48,  12,   8,  26,  96,  12 },
        { 48,  12, 168,  10,  96,  12 },
        { 48,  12, 168,  26,  96,  12 },
        { 48,  12, 328,  10,  96,  12 },
        { 48,  12, 328,  26,  96,  12 },
        -- panels
        { 16,  16,   8,  56,  48,  16 },
        {  8,  16,  56,  56,   8,  16 },
        { 16,  16,  64,  56,  16,  16 },
        { 16,  16,   8,  72,  48,  16 },
        {  8,  16,  56,  72,   8,  16 },
        { 16,  16,  64,  72,  16,  16 },
        { 16,  16,   8,  88,  48,  16 },
        {  8,  16,  56,  88,   8,  16 },
        { 16,  16,  64,  88,  16,  16 },
        { 16,  16,   8, 104,  48,  16 },
        {  8,  16,  56, 104,   8,  16 },
        { 16,  16,  64, 104,  16,  16 },
        { 16,  16,   8, 120,  48,  16 },
        {  8,  16,  56, 120,   8,  16 },
        { 16,  16,  64, 120,  16,  16 },
        -- buttons
        { 16,  16,   8, 176, 144,  16 },
        { 16,  16,   8, 192, 144,  16 },
        { 16,  16,   8, 208, 144,  16 },
    },
}

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
            local dir_path = data_dir .. '/' .. dir

            local filenames = love.filesystem.getDirectoryItems(dir_path)
            local base_path = love.filesystem.getRealDirectory(dir_path)
            for _, filename in ipairs(filenames) do     
                if not string.find(filename, '.*%.lua') then goto continue end

                local filepath = base_path .. '/' .. dir_path .. '/' .. filename
                local getContents = assert(loadfile(filepath))
                local definition = getContents()

                EntityFactory.register(definition)

                ::continue::
            end 
        end
    end
end

local function loadGraphics(type)     
    local path = 'gfx/' .. type .. '.png'
    -- TODO: check if file exists

    local image = love.graphics.newImage(path)
    image:setFilter('nearest', 'nearest')
    TextureCache:register(type, image)

    local quads = {}
    local quads_list = ASSETS[type]
    for _, quads_item in ipairs(quads_list) do
        for _, quad in ipairs(QuadGenerator.generate(image, unpack(quads_item))) do
            table.insert(quads, quad)
        end
    end

    QuadCache:register(type, quads)
end

local function addGameGraphicsLoaders(runners)
    table.insert(runners, { Runner(function() loadGraphics('uf_terrain') end),      'load terrain'          })
    table.insert(runners, { Runner(function() loadGraphics('uf_heroes') end),       'load heroes'           })
    table.insert(runners, { Runner(function() loadGraphics('uf_items') end),        'load items'            })
    table.insert(runners, { Runner(function() loadGraphics('uf_fx_impact') end),    'load impact effects'   })
    table.insert(runners, { Runner(function() loadGraphics('uf_skills') end),       'load skills'           })
    table.insert(runners, { Runner(function() loadGraphics('uf_fx') end),           'load effects'          })
    table.insert(runners, { Runner(function() loadGraphics('actionbar') end),       'load action bar icons' })
    table.insert(runners, { Runner(function() loadGraphics('projectiles') end),     'load projectiles'      })
end

local function addGameAssetLoaders(runners)
    table.insert(runners, { Runner(loadEntities),               'load entities' })
    table.insert(runners, { Runner(loadLevels, onLoadLevels),   'load levels' })
end

local function addShaderLoaders(runners)
    table.insert(runners, { Runner(loadShaders), 'load shaders' })
end

local function addUIGraphicsLoaders(runners)
    table.insert(runners, { Runner(function() loadGraphics('uf_interface') end),    'load interface'  })
    table.insert(runners, { Runner(function() loadGraphics('uf_portraits') end),    'load portraits'  })
    table.insert(runners, { Runner(function() loadGraphics('border') end),          'load border'     })
    -- TODO: cleaner if we can load health bar as part of graphics, but needs to know quads
    table.insert(runners, { Runner(HealthBar.preload),                              'load health bar' }) 
end

Loading.new = function(T, opts, ...)
    opts = opts or 'all' -- 'ui', 'game', 'none'
    local args = {...}

    local background = love.graphics.newImage('gfx/loading.png')
    local background_w, background_h = background:getDimensions()

    local text = 'LOADING'
    local text_h = FONT:getHeight()
    local text_x = mfloor((WINDOW_W - FONT:getWidth(text)) / 2)
    local text_y = mfloor((WINDOW_H - FONT:getHeight()) / 2)

    local time = MINIMUM_LOAD_DURATION

    local runners = {}
    
    if opts == 'ui' or opts == 'all' then
        addUIGraphicsLoaders(runners)
    end

    if opts == 'game' or opts == 'all' then
        addGameGraphicsLoaders(runners)
        addShaderLoaders(runners)
        addGameAssetLoaders(runners)
    end

    -- load assets in this order and show appropriate message

    local runner, message, message_x = nil, nil, 0

    local enter = function(self)
        runner, message = unpack(table.remove(runners, 1))
        message_x = mfloor((WINDOW_W - FONT:getWidth(message)) / 2)
    end

    local update = function(self, dt)
        time = mmax(time - dt, 0)

        local is_runner_done = runner:update()
        if is_runner_done and #runners > 0 then
            runner, message = unpack(table.remove(runners, 1))
            message_x = mfloor((WINDOW_W - FONT:getWidth(message)) / 2)
        elseif is_runner_done and #runners == 0 and time == 0 then
            return Gamestate.switch(T(unpack(args)))
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
