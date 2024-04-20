local M = {}

M.parseFlags = function(flags)
    local val = 0

    for idx, flag in pairs(flags) do
        if flag == 'PR' then
            val = bit.bor(val, FLAGS.projectile)
        end
    end

    return val
end

M.hasFlag = function(value, flag)
    return bit.band(value, flag) == flag
end

return M
