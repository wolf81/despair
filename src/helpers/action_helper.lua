--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, mmax = math.floor, math.max

local M = {}

M.getMoveCost = function(entity, ...)
    local coords = {...}
    assert(#coords > 0, 'missing argument(s): coords')

    local move_speed = entity:getComponent(MoveSpeed)
    local base_ap = move_speed:getValue()
    local ap = 0

    local prev_coord = entity.coord

    for _, coord in ipairs(coords) do
        local dxy = entity.coord - prev_coord
        local direction = Direction.fromHeading(dxy.x, dxy.y)
        if Direction.isOrdinal(direction) then
            ap = ap + mfloor(base_ap * ORDINAL_MOVE_FACTOR)
        else
            ap = ap + base_ap
        end
         prev_coord = coord
    end

    return ap
end

M.getAttackCost = function(entity)
    return 30
end

M.getDestroyCost = function(entity)
    local control = entity:getComponent(Control)
    local ap = control:getAP()
    return mmax(ap, 0)
end

M.getIdleCost = function(entity)
    return 30
end

return M
