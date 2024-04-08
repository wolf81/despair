--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Move = {}

local ORDINAL_COST_FACTOR = 1.4

local function tweenMoves(duration, entity, coords, fn)
    local coord = table.remove(coords, 1)

    Timer.tween(duration, entity, { coord = coord }, 'linear', function()
        entity.coord = coord

        if #coords > 0 then
            tweenMoves(duration, entity, coords, fn)
        else
            fn()
        end    
    end)
end

local function getTotalMoveCost(entity, coords)
    local cost = 0

    local move_speed = entity:getComponent(MoveSpeed)
    
    local prev_coord = entity.coord
    for _, coord in ipairs(coords) do
        local dxy = entity.coord - prev_coord
        local direction = Direction.fromHeading(dxy.x, dxy.y)        
        if Direction.isOrdinal(direction) then
            cost = cost + mfloor(move_speed:getValue() * ORDINAL_COST_FACTOR)
        else
            cost = cost + move_speed:getValue()
        end

        prev_coord = coord
    end

    return cost
end

Move.new = function(level, entity, ...)
    local did_execute, is_finished = false, false

    local coords = {...}
    assert(#coords > 0, 'missing variable arguments for coords')

    local coord = coords[1]

    local cost = getTotalMoveCost(entity, coords)

    local execute = function(self, duration, fn)
        if did_execute then return end

        did_execute = true

        Signal.emit('move', entity, coords[#coords], duration)

        tweenMoves(duration / #coords, entity, coords, function() 
            is_finished = true
        end)
    end

    local getCost = function(self) return cost end

    local isFinished = function(self) return is_finished end

    return setmetatable({
        -- methods
        execute     = execute,
        getCost     = getCost,
        isFinished  = isFinished,
    }, Move)
end

return setmetatable(Move, {
    __call = function(_, ...) return Move.new(...) end,
})
