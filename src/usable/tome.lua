--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Tome = {}

Tome.new = function(entity, def)
    local use = function(source, target, level, duration)
        return false
    end
    
    return setmetatable({
        -- methods
        use = use,
    }, Tome)
end

return setmetatable(Tome, {
    __call = function(_, ...) return Tome.new(...) end,
})
