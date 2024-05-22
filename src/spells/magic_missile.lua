--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MagicMissile = {}

local function getLevel(entity)
    local class = entity:getComponent(Class)
    local npc = entity:getComponent(NPC)
    return class:getLevel() or npc:getLevel()
end

MagicMissile.new = function(level, entity, coord)
    local level = getLevel(entity)

    local draw = function(self)
        -- body
    end

    local update = function(self, dt)
        -- body
    end

    return setmetatable({
        -- methods
        draw    = draw,
        update  = update,
    }, MagicMissile)
end

return setmetatable(MagicMissile, {
    __call = function(_, ...) return MagicMissile.new(...) end,
})
