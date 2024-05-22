--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local bband, bbor = bit.band, bit.bor

local M = {}

M.parseFlags = function(flags, type)
    local val = 0

    -- TODO: clean-up per type, maybe not group all together under FLAGS

    if type == 'spell' then
        for idx, flag in pairs(flags) do
            if flag == 'A' then 
                val = bbor(val, FLAGS.arcane)
            elseif flag == 'D' then
                val = bbor(val, FLAGS.devine)
            end
        end
    else
        for idx, flag in pairs(flags) do
            if flag == 'PR' then
                val = bbor(val, FLAGS.projectile)
            elseif flag == 'NW' then            
                val = bbor(val, FLAGS.natural_weapon)
            elseif flag == 'SB' then
                val = bbor(val, FLAGS.shadow_blend)
            end
        end
    end

    return val
end

M.hasFlag = function(value, flag) return bband(value, flag) == flag end

return M
