--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local NPC = {}

NPC.new = function(entity, def)
    local hd = def['hd']
    assert(hd ~= nil, 'missing field: "hd"')

    local ac = def['ac']
    assert(ac ~= nil, 'missing field: "ac"')
    
    local level = ndn.dice(hd).count()

    local getLevel = function(self) return level end

    local getArmorClass = function(self) return ac end

    return setmetatable({
        -- methods
        getLevel        = getLevel,
        getArmorClass   = getArmorClass,
    }, NPC)
end

return setmetatable(NPC, {
    __call = function(_, ...) return NPC.new(...) end,
})
