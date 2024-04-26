--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local bband, bbor = bit.band, bit.bor

local M = {}

M.parseFlags = function(flags)
    local val = 0

    for idx, flag in pairs(flags) do
        if flag == 'PR' then
            val = bbor(val, FLAGS.projectile)
        elseif flag == 'NW' then            
            val = bbor(val, FLAGS.natural_weapon)
        end
    end

    return val
end

M.hasFlag = function(value, flag) return bband(value, flag) == flag end

return M
