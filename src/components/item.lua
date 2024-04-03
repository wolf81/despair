--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Item = {}

Item.new = function(entity, def)
    return setmetatable({
        -- methods
    }, Item)
end

return setmetatable(Item, {
    __call = function(_, ...) return Item.new(...) end,
})
