local Cartographer = {}

local RENDER_SCALE = 2.0

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

local function generateChartImage(chart)
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

Cartographer.new = function(entity, def)
    local stats = entity:getComponent(Stats)
    local skills = entity:getComponent(Skills)
    assert(stats ~= nil, 'missing component: "Stats"')
    assert(skills ~= nil, 'missing component: "Skills"')

    local charts, chart, chart_image = {}, nil, nil

    local isCoordVisible = function(coord) end

    local setLevel = function(self, level_idx, fn)
        isCoordVisible = fn or function(coord) return true end

        if charts[level_idx] == nil then
            charts[level_idx] = newChart(MAP_SIZE)
        end

        chart = charts[level_idx]
    end

    local updateChart = function(self, coord, map)
        local mind = stats:getBonus('mind')
        local know = skills:getValue('know')

        local range = math.max((mind + know - 4), 0)
        local needs_update = false

        local x1, x2 = math.max(coord.x - range, 1), math.min(coord.x + range, MAP_SIZE)
        local y1, y2 = math.max(coord.y - range, 1), math.min(coord.y + range, MAP_SIZE)

        for y = y1, y2 do
            for x = x1, x2 do
                if not isCoordVisible(x, y) then goto continue end

                local map_tile = map:getTile(x, y)
                local chart_tile = chart[y][x]
                if chart_tile ~= map_tile then
                    chart[y][x] = map_tile
                    needs_update = true
                end

                ::continue::
            end
        end

        if needs_update then
            chart_image = generateChartImage(chart)
            needs_update = false
        end
    end

    local getChartImage = function(self, color) return chart_image end

    local getSize = function(self) return MAP_SIZE * RENDER_SCALE, MAP_SIZE * RENDER_SCALE end

    return setmetatable({
        -- methods
        setLevel        = setLevel,
        updateChart     = updateChart,
        getChartImage   = getChartImage,
        getSize         = getSize,
    }, Cartographer)
end

return setmetatable(Cartographer, {
    __call = function(_, ...) return Cartographer.new(...) end,
})
