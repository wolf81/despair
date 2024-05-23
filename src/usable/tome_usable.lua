--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local TomeUsable = {}

TomeUsable.new = function(entity, def)
    local use = function(self, source, target, level, duration)
        return false
    end
    
    return setmetatable({
        -- methods
        use = use,
    }, TomeUsable)
end

return setmetatable(TomeUsable, {
    __call = function(_, ...) return TomeUsable.new(...) end,
})
