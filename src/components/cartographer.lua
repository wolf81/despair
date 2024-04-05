local Cartographer = {}

local function newMap(size)
    local map = {}

    for y = 1, size do
        map[y] = {}
        for x = 1, size do
            map[y][x] = 0
        end
    end

    return map
end

Cartographer.new = function(entity, def)
    local maps = {}

    local stats = entity:getComponent(Stats)
    local skills = entity:getComponent(Skills)

    local setLevel = function(self, level_idx)
        if maps[level_idx] == nil then            
            table.insert(maps, newMap(MAP_SIZE))
        end
    end

    local updateMap = function(self, coord, level)
        local mind = stats:getBonus('mind')
        local know = skills:getValue('know')

        local v = math.max((mind + know - 4), 0)
        print('v', v)
    end

    return setmetatable({
        -- methods
        setLevel    = setLevel,
        updateMap   = updateMap,
    }, Cartographer)
end

return setmetatable(Cartographer, {
    __call = function(_, ...) return Cartographer.new(...) end,
})
