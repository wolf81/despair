--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

--  Based on name_generator.js by drow <drow@bin.sh>
--  See: https://donjon.bin.sh/code/name/

local M = {}

local name_set = {}
local chain_cache = {}

local function selectLink(chain, key)
    local len = chain['table_len'][key]
    
    if not len then return false end

    local idx = math.random(1, len)
    local acc = 1
    for token, count in pairs(chain[key]) do
        acc = acc + count
        if acc > idx then return token end
    end

    return false
end

local function incrementChain(chain, key, token)
    if not chain[key] then chain[key] = {} end

    local value = chain[key][token] or 0
    chain[key][token] = value + 1

    return chain
end

local function scaleChain(chain)
    local table_len = {}

    for key, value in pairs(chain) do
        table_len[key] = 0

        for token, count in pairs(value) do
            local weighted = math.floor(math.pow(count, 1.3))
            chain[key][token] = weighted
            table_len[key] = table_len[key] + weighted
        end
    end

    chain['table_len'] = table_len
    return chain
end

-- Construct markov chain from list of names
local function constructChain(list)
    local chain = {}

    for _, list_item in ipairs(list) do
        local names = {}
        for name in list_item:gmatch("[^%s]+") do
            names[#names + 1] = name
        end

        chain = incrementChain(chain, 'parts', #names)

        for _, name in ipairs(names) do
            chain = incrementChain(chain, 'name_len', #name)

            local char = string.sub(name, 1, 1)
            chain = incrementChain(chain, 'initial', char)

            local last_char = char
            for i = 2, #name do
                char = string.sub(name, i, i)
                chain = incrementChain(chain, last_char, char)
                last_char = char
            end
        end
    end

    return scaleChain(chain)
end

-- Get markov chain by type
local function markovChain(type)
    local chain = chain_cache[type]

    if not chain then
        local list = name_set[type]
        if list and #list > 0 then
            chain = constructChain(list)
            chain_cache[type] = chain
        end
    end

    return chain
end

-- Construct name from markov chain
local function markovName(chain)
    local parts = selectLink(chain, 'parts')
    local names = {}

    for i = 1, parts do
        local name_len = selectLink(chain, 'name_len')
        local char = selectLink(chain, 'initial')
        local name = char
        local last_char = char

        while #name < name_len do
            char = selectLink(chain, last_char)
            
            if not char then break end

            name = name .. char
            last_char = char
        end

        names[#names + 1] = name
    end

    return table.concat(names, ' ')
end

M.generate = function(race, gender, fn)
    local type = race..'-'..gender

    if not name_set[type] then name_set[type] = fn(type) end

    local chain = markovChain(type)
    if chain then
        return markovName(chain)
    end

    return ''
end

return M
