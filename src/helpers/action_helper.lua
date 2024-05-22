--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, mmax = math.floor, math.max

local BASE_ACTION_COST = 30

-- Microlite20 movement speed is based on the following assumptions based on D&D:
-- * movement speed is in yards per round
-- * a round is 10 turns (and a turn is 6 seconds)
-- * a tile is 5 yards squared
--
-- Keeping the above in mind, a movement speed of 30 would result in:
-- * 30 / 5 yards / 10 turns * 30 AP = 18 AP
-- * for diagonal movement the AP cost is multiplied by sqrt(2)
-- 
-- The AP value is not something in Microlite, but used in DoD to normalize action cost.
local MOVE_FACTOR = 1 / 5 / 10 * BASE_ACTION_COST

local M = {}

M.getMoveCost = function(entity, ...)
    local coords = {...}
    assert(#coords > 0, 'missing argument(s): coords')

    local move_speed = entity:getComponent(MoveSpeed)
    local move_ap = move_speed:getValue() * MOVE_FACTOR
    local total_ap = 0

    local prev_coord = entity.coord

    for _, coord in ipairs(coords) do
        local dxy = entity.coord - prev_coord
        local direction = Direction.fromHeading(dxy.x, dxy.y)
        if Direction.isOrdinal(direction) then
            total_ap = total_ap + mfloor(move_ap * ORDINAL_MOVE_FACTOR)
        else
            total_ap = total_ap + move_ap
        end
         prev_coord = coord
    end

    return total_ap
end

M.getAttackCost = function(entity) return BASE_ACTION_COST end

M.getDestroyCost = function(entity) return mmax(entity:getComponent(Control):getAP(), 0) end

M.getIdleCost = function(entity) return BASE_ACTION_COST end

M.getRestCost = function(entity) return BASE_ACTION_COST end

M.getUseCost = function(entity) return BASE_ACTION_COST end

M.getSpellCost = function(entity) return BASE_ACTION_COST end

return M
