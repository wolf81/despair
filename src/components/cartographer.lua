--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmin, mmax, mfloor = math.min, math.max, math.floor

local Cartographer = {}

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

        -- TODO: scale range better - MIND should have height weight than KNOWLEDGE
        local range = mmin(mmax(mind + know - 1, 0), 6)
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

    local getChart = function(self) return chart end

    return setmetatable({
        -- methods
        setLevel    = setLevel,
        getChart    = getChart,
        updateChart = updateChart,
    }, Cartographer)
end

return setmetatable(Cartographer, {
    __call = function(_, ...) return Cartographer.new(...) end,
})
