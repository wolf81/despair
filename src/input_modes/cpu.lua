--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom, mfloor = love.math.random, math.floor

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W, Direction.NW, Direction.SW, Direction.NE, Direction.SE }
    return dirs[lrandom(#dirs)]
end

Cpu.new = function(entity)
    local action = nil

    local getAction = function(self, level, ap)
        local player = level:getPlayer()

        local distance = player.coord:dist(entity.coord)
        if distance < 2 then
            local equip = entity:getComponent(Equipment)
            if equip:equipMelee() then
                return Attack(level, entity, player)
            end
        elseif distance < 10 then
            local equip = entity:getComponent(Equipment)
            if equip:equipRanged() then
                -- check line of sight
                if level:inLineOfSight(entity.coord, player.coord) then
                    return Attack(level, entity, player)
                end
            end
        end

        local move_speed = entity:getComponent(MoveSpeed)
        local ap_cost = move_speed:getValue()

        local coord = entity.coord
        local coords = {}
        while ap > 0 do    
            -- try to move in a random direction
            local direction = getRandomDirection()
            local next_coord = coord + direction

            if not level:isBlocked(next_coord) and #level:getEntities(next_coord) == 0 then
                table.insert(coords, next_coord)
                coord = next_coord

                if Direction.isOrdinal(direction) then
                    ap = ap - mfloor(ap_cost * 1.4)
                else
                    ap = ap - ap_cost
                end
            else
                table.insert(coords, coord)
                ap = ap - ap_cost
            end
        end

        if #coords > 0 then
            return Move(level, entity, unpack(coords))
        end

        return nil
    end

    return setmetatable({
        -- methods
        getAction   = getAction,
    }, Cpu)
end

return setmetatable(Cpu, {
    __call = function(_, ...) return Cpu.new(...) end,
})
