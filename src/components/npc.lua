--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local NPC = {}

NPC.new = function(entity, def)
    local hd = def['hd']
    assert(hd ~= nil, 'missing field: "level" or "hd"')
    
    local level = ndn.dice(hd).count()

    local getLevel = function(self) return level end

    return setmetatable({
        -- methods
        getLevel = getLevel,
    }, NPC)
end

return setmetatable(NPC, {
    __call = function(_, ...) return NPC.new(...) end,
})
