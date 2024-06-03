--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin, mmax, mfloor = math.min, math.max, math.floor

local Cartographer = {}

local RENDER_SCALE = 2.0

local function generateChartImage(chart, level_idx)
    local image_size = MAP_SIZE * RENDER_SCALE

    local canvas = love.graphics.newCanvas(image_size, image_size)
    canvas:renderTo(function() 
        for y = 1, MAP_SIZE do
            for x = 1, MAP_SIZE do
                local value = chart[y][x] 

                if value == math.huge or value == 1 then goto continue end

                if value == 0 then
                    love.graphics.setColor(1.0, 1.0, 1.0, 0.3)
                else
                    love.graphics.setColor(0.0, 0.0, 0.0, 0.9)
                end

                local ox = x * RENDER_SCALE
                local oy = y * RENDER_SCALE
                love.graphics.rectangle('fill', ox, oy, RENDER_SCALE, RENDER_SCALE)

                ::continue::
            end
        end
    end)

    return love.graphics.newImage(canvas:newImageData())
end

local function newChart(size)
    local chart = {}
    for y = 1, size do 
        chart[y] = {}
        for x = 1, size do
            chart[y][x] = math.huge
        end
    end
    return chart
end

Cartographer.new = function(entity, def)
    local stats = entity:getComponent(Stats)
    local skills = entity:getComponent(Skills)
    assert(stats ~= nil, 'missing component: "Stats"')
    assert(skills ~= nil, 'missing component: "Skills"')

    local charts, chart = {}, nil    

    local level_idx = 0

    local chart_image, needs_update = nil, true

    local background = TextureGenerator.generateParchmentTexture(120, 120)

    local frame = Rect(0)

    local mapCoord = function(x, y, tile) 
        if chart[y][x] ~= tile then
            chart[y][x] = tile
            needs_update = true
        end
    end

    local isCoordVisible = function(coord) end

    local getLevel = function(self) return level_idx end

    local setLevel = function(self, level_idx_, fn)
        level_idx = level_idx_
        isCoordVisible = fn or function(coord) return true end

        if charts[level_idx] == nil then
            charts[level_idx] = newChart(MAP_SIZE)
        end

        needs_update = true

        chart = charts[level_idx]
    end

    local draw = function()
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)
        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)

        local title = "LEVEL " .. level_idx
        local title_x = mfloor((w - FONTS['default']:getWidth(title)) / 2)
        love.graphics.print(title, x + title_x, y + 10)

        local chart_w, chart_h = chart_image:getDimensions()
        local chart_x = mfloor((w - chart_w) / 2)

        love.graphics.draw(chart_image, x + chart_x, y + 20)
    end

    local updateChart = function(self, coord, map)
        local mind = stats:getBonus('mind')
        local know = skills:getValue('know')

        -- TODO: scale range better - MIND should have height weight than KNOWLEDGE
        local range = mmin(mmax(mind + know - 1, 0), 6)
        local needs_update = false

        local x1, x2 = mmax(coord.x - range, 1), mmin(coord.x + range, MAP_SIZE)
        local y1, y2 = mmax(coord.y - range, 1), mmin(coord.y + range, MAP_SIZE)

        for y = y1, y2 do
            for x = x1, x2 do
                if not isCoordVisible(x, y) then goto continue end

                mapCoord(x, y, map:getTile(x, y))

                ::continue::
            end
        end

        self:update()
    end

    local update = function(self) 
        if needs_update then
            chart_image = generateChartImage(chart, level_idx)
            needs_update = false
        end
    end

    local getSize = function(self) return background:getDimensions() end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    -- set intial level
    setLevel(nil, 1)

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        setFrame    = setFrame,
        setLevel    = setLevel,
        updateChart = updateChart,
    }, Cartographer)
end

return setmetatable(Cartographer, {
    __call = function(_, ...) return Cartographer.new(...) end,
})
