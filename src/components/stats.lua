--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Stats = {}

Stats.new = function(entity, def)
    local stats = {
        str  = def['str'],
        dex  = def['dex'],
        mind = def['mind'],
    }

    local getValue = function(self, stat) return stats[stat] end

    local getBonus = function(self, stat) return mfloor((stats[stat] - 10) / 2) end

    return setmetatable({
        -- methods
        getValue    = getValue,
        getBonus    = getBonus,
    }, Stats)
end

return setmetatable(Stats, {
    __call = function(_, ...) return Stats.new(...) end,
})
