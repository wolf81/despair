--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Stats = {}

Stats.new = function(entity, def)
    local stats = {
        str  = def['str'],
        dex  = def['dex'],
        mind = def['mind'],
    }

    -- points available to assign to any stat
    local points = 0

    local getValue = function(self, stat) return stats[stat] end

    local getBonus = function(self, stat) return mfloor((stats[stat] - 10) / 2) end

    local addPoints = function(self, points_) points = points_ end

    local getPoints = function(self) return points end

    local assignPoints = function(self, points_, stat)
        assert(stats ~= nil, 'missing argument: "stat"')
        assert(stats[stat] ~= nil, 'invalid stat: "' .. stat .. '"')
        assert(points_ <= points, 'out of range: "points_"')

        points = points - points_

        stats[stat] = stats[stat] + points_
    end

    return setmetatable({
        -- methods
        assignPoints    = assignPoints,
        getPoints       = getPoints,
        addPoints       = addPoints,
        getValue        = getValue,
        getBonus        = getBonus,
    }, Stats)
end

return setmetatable(Stats, {
    __call = function(_, ...) return Stats.new(...) end,
})
