--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Direction = {
    NONE = vector( 0,  0),
    N    = vector( 0, -1),
    S    = vector( 0,  1),
    E    = vector( 1,  0),
    W    = vector(-1,  0),
    NW   = vector(-1, -1),
    NE   = vector( 1, -1),
    SW   = vector(-1,  1),
    SE   = vector( 1,  1),
}

--[[
-- TODO: consider just checking if value larger than 0x8 or perhaps check
-- if 2nd bit from right is not 0
Direction.isOrdinal = function(dir)
    return dir.x ~= 0 and dir.y ~= 0
end

-- get direction from a vector
Direction.fromHeading = function(x, y)
    if x == 0 and y < 0 then return Direction.N
    elseif x == 0 and y > 0 then return Direction.S
    elseif x > 0 and y == 0 then return Direction.E
    elseif x < 0 and y == 0 then return Direction.W
    elseif x < 0 and y < 0 then return Direction.NW
    elseif x > 0 and y < 0 then return Direction.NE
    elseif x < 0 and y > 0 then return Direction.SW
    elseif x > 0 and y > 0 then return Direction.SE
    else return Direction.NONE end
end
--]]

return Direction
