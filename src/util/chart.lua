--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Chart = {}

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

Chart.new = function(level_idx, size)
    local chart_image, needs_update = nil, true

    local chart = newChart(size)

    local getImage = function(self) return chart_image end

    local mapCoord = function(self, x, y, tile) 
        if chart[y][x] ~= tile then
            chart[y][x] = tile
            needs_update = true
        end
    end

    local getLevelIndex = function(self) return level_idx end

    local getSize = function(self) return MAP_SIZE * RENDER_SCALE, MAP_SIZE * RENDER_SCALE end

    local update = function(self)
        if needs_update then
            chart_image = generateChartImage(chart, level_idx)
            needs_update = false
        end
    end

    return setmetatable({
        getLevelIndex   = getLevelIndex,
        getImage        = getImage,
        mapCoord        = mapCoord,
        getSize         = getSize,
        update          = update,
    }, Chart)
end

return setmetatable(Chart, {
    __call = function(_, ...) return Chart.new(...) end,
})
