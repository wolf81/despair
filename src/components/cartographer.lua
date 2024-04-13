--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmin, mmax = math.min, math.max

local Cartographer = {}

--[[
local RENDER_SCALE = 2.0

local function newChart(size, level_idx)
    local chart = {
        level_idx = level_idx,
    }

    for y = 1, size do
        chart[y] = {}
        for x = 1, size do
            chart[y][x] = math.huge
        end
    end

    return chart
end

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
--]]

Cartographer.new = function(entity, def)
    local stats = entity:getComponent(Stats)
    local skills = entity:getComponent(Skills)
    assert(stats ~= nil, 'missing component: "Stats"')
    assert(skills ~= nil, 'missing component: "Skills"')

    local charts, chart = {}, nil    

    local isCoordVisible = function(coord) end

    local setLevel = function(self, level_idx, fn)
        isCoordVisible = fn or function(coord) return true end

        if charts[level_idx] == nil then
            charts[level_idx] = Chart(level_idx, MAP_SIZE)
        end

        chart = charts[level_idx]
    end

    local updateChart = function(self, coord, map)
        local mind = stats:getBonus('mind')
        local know = skills:getValue('know')

        local range = mmax((mind + know - 4), 0)
        local needs_update = false

        local x1, x2 = mmax(coord.x - range, 1), mmin(coord.x + range, MAP_SIZE)
        local y1, y2 = mmax(coord.y - range, 1), mmin(coord.y + range, MAP_SIZE)

        for y = y1, y2 do
            for x = x1, x2 do
                if not isCoordVisible(x, y) then goto continue end

                chart:mapCoord(x, y, map:getTile(x, y))

                ::continue::
            end
        end

        chart:update()
    end

    local getChartImage = function(self, color) return chart:getImage() end

    local getLevelIndex = function(self) return chart:getLevelIndex() end

    local getSize = function(self) return chart:getSize() end

    return setmetatable({
        -- methods
        setLevel        = setLevel,
        updateChart     = updateChart,
        getChartImage   = getChartImage,
        getLevelIndex   = getLevelIndex,
        getSize         = getSize,
    }, Cartographer)
end

return setmetatable(Cartographer, {
    __call = function(_, ...) return Cartographer.new(...) end,
})
