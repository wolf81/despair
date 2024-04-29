--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local bband, blshift, brshift = bit.band, bit.lshift, bit.rshift
local strsub, strbyte, mfloor = string.sub, string.byte, math.floor

local M = {}

-- the initial seed is always set to 1
local seed = 1

-- the maximum number used to calculate float values
local FLOAT_INT_MAX = 0x8000

local randomInt = function(max)
    -- force use of 64 bit numbers here by using hex constants and ULL 
    -- annotation, to prevent loss of precision, in line with JavaScript code
    seed = 1103515245 * seed + 12345
    seed = bband(seed, 0x7FFFFFFF)

    return tonumber(brshift(seed, 8) % max)
end

-- compute a seed from a string
local computeSeed = function(str)
    local s = 42
    for i = 1, #str do
        local char = strsub(str, i, i)
        s = blshift(s, 5) - s + strbyte(char)
        s = bband(s, 0x7FFFFFFF)
    end
    return s
end

-- generate a random number between min and max
M.random = function(min, max)    
    if min and max then
        return mfloor(randomInt(max - min) + min)
    elseif min then
        return mfloor(randomInt(min) + 1)
    else
        return randomInt(FLOAT_INT_MAX) / FLOAT_INT_MAX
    end
end

-- seed the random number generator with a number, string or if no argument
-- is provided, with an integer based on time
-- this function will also return the seed
M.randomseed = function(s)
    local seed_type = type(s)
    if seed_type == 'number' then
        seed = mfloor(s)
    elseif seed_type == 'string' then
        seed = computeSeed(s)
    elseif s == nil then
        seed = os.time()
    else
        error('invalid argument, provide a number, string or no argument')
    end

    return seed
end

return M
