--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local lrandom = love.math.random

local Cpu = {}

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W, Direction.NW, Direction.SW, Direction.NE, Direction.SE }
    return dirs[lrandom(#dirs)]
end

Cpu.new = function(entity)
    local ap = -1

    local getAction = function(self, level)
        if ap < 0 then return nil end

        local action = nil

        local player = level:getPlayer()
        
        local distance = player.coord:dist(entity.coord)
        if distance < 2 then
            local equip = entity:getComponent(Equipment)
            if equip:equipMelee() then
                action = Attack(level, entity, player)
            end
        elseif distance < 10 then
            local equip = entity:getComponent(Equipment)
            if equip:equipRanged() then
                -- check line of sight
                if level:inLineOfSight(entity.coord, player.coord) then
                    action = Attack(level, entity, player)
                end
            end
        end

        if not action then
            -- try to move in a random direction
            local direction = getRandomDirection()
            local next_coord = entity.coord + direction

            -- ensure entity can move to next coord
            if not level:isBlocked(next_coord) and #level:getEntities(next_coord) == 0 then
                action = Move(level, entity, next_coord, direction)
            else
                action = Idle(level, entity)
            end
        end

        if action then 
            ap = ap - action:getCost() 
        end

        return action
    end

    local addAP = function(self, value)
        ap = ap + value
    end

    return setmetatable({
        -- methods
        getAction   = getAction,
        addAP       = addAP,
    }, Cpu)
end

return setmetatable(Cpu, {
    __call = function(_, ...) return Cpu.new(...) end,
})
