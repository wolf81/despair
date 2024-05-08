--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

--  Based on name_generator.js by drow <drow@bin.sh>
--  See: https://donjon.bin.sh/code/name/

local M = {}

local cache = {}
local names = {}

local split = function(str, delim)
    local parts = {}
    
    for token in string.gmatch(str, "[^%s]+") do
       table.insert(parts, token)
    end

    return parts
end

local join = function(tbl, delim)
    delim = delim or ' '

    local str = ''
    for idx, val in ipairs(tbl) do
        str = str .. val

        if idx < #tbl then
            str = str .. delim
        end
    end

    return str
end

local incrementChain = function(chain, key, token)
    local chain_key_info = chain[key] or {}
    local token_value = chain_key_info[token] or 0
    token_value = token_value + 1
    chain_key_info[token] = token_value
    chain[key] = chain_key_info
end

local scaleChain = function(chain)
    local table_len = {}

    for key, value in pairs(chain) do
        print('scaleChain kv', key, value)
        table_len[key] = 0

        print('-')
        for k,v in pairs(chain[key]) do
            print('', k, v)
        end
        print('-')

        for token, count in pairs(chain[key]) do
            local weighted = math.floor(math.pow(count, 1.3))
            chain[key][token] = weighted
            print('scaleChain weighted:', weighted)

            table_len[key] = table_len[key] + weighted
        end
    end
    chain['table_len'] = table_len
end

local constructChain = function(full_names)
    local chain = {}

    for i, full_name in ipairs(full_names) do
        local names = split(full_name)
        print('constructChain #names:', #names, full_name)
        incrementChain(chain, 'parts', #names)
        
        for j, name in ipairs(names) do
            print('constructChain name', name)
            incrementChain(chain, 'name_len', #name)

            local char = string.sub(name, 1, 1)
            incrementChain(chain, 'initial', char)

            print('initial', char, #name)

            local last_char = char
            for i = 2, #name do
                char = string.sub(name, i, i)
                incrementChain(chain, last_char, char)
                print(last_char .. ' -> ' .. char)
                last_char = char
            end
        end
    end

    scaleChain(chain)
   
    return chain 
end

local markovChain = function(type, fn)
    local chain = cache[type]
    
    if not chain then
        local list = fn(type)
        chain = constructChain(list)
            print('ch', chain)
        cache[type] = chain
    end

    return chain
end

local selectLink = function(chain, key)
    print('selectLink key:', key)
    local len = chain['table_len'][key]
    local idx = math.floor(math.random() * len)
    local t = 0
    print('selectLink len:', len)

    for _, token in pairs(chain[key]) do
        print('token:', token)
        t = t + chain[key][token]
        print('t:', t)
        if idx < t then return token end
    end

    return '-'
end

local markovName = function(chain)
    local parts = selectLink(chain, 'parts')
    print('markovName parts:', parts)
    local names = {}

    for i = 1, #parts do
        print('markovName part', part)
        local name_len = selectLink(chain, 'name_len')
        local char = selectLink(chain, 'initial')
        local name = char
        local last_char = char

        while #name < name_len do
            char = selectLink(chain, last_char)
            name = name .. char
            last_char = char
        end

        print('markovName name', name)

        table.insert(names, name)
    end
    
    return join(names, ' ')
end

M.generate = function(race, gender, fn)
    local type = race..'-'..gender

    local chain = markovChain(type, fn)
    if chain then
        return markovName(chain)
    end

    return ''
end

return M
