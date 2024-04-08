--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Mouse = {}

local function tryGetEnemy(level, coord)
    local entities = level:getEntities(coord, function(e) return e.type == 'npc' end)
    if #entities > 0 then
        local target = entities[1]
        local health = target:getComponent(Health)
        if health:isAlive() then
            return target
        end
    end

    return nil
end

-- check if any weapon kind is equipped from a list of weapon kinds
-- valid weapon kinds can be: 1h, 2h, light, ranged_1h, ranged_2h, ...
local isWeaponKindEquipped = function(entity, ...)
    local kinds = { ... }
    assert(#kinds > 0, 'missing argument(s): kinds')

    local equip = entity:getComponent(Equipment)
    local weapon = equip:getItem('mainhand', function(item) 
        for _, kind in ipairs(kinds) do
            if kind == item.kind then return true end
        end
        return false
    end)

    return weapon ~= nil
end

Mouse.new = function(entity)
    local getAction = function(self, level, ap)
        if not love.mouse.isDown(1) then return end

        local mouse_coord = Pointer.getCoord()

        -- skip turn if player clicked on himself
        if mouse_coord == entity.coord then return Idle(level, entity) end

        -- if we have a target at mouse coord then:
        -- 1. if target is at ranged distance (ignore adjacent tiles)
        -- 2. if a ranged weapon is equipped
        -- 3. perform attack
        local target = tryGetEnemy(level, mouse_coord)
        if target ~= nil and target.coord ~= entity.coord then
            local dist = target.coord:dist(entity.coord)
            if dist > 1.5 and isWeaponKindEquipped(entity, 'ranged_1h', 'ranged_2h') then
                return Attack(level, entity, target)
            end
        end

        -- try move in mouse direction
        local dxy = mouse_coord - entity.coord
        local direction = Direction.fromHeading(dxy.x, dxy.y)
        local next_coord = entity.coord + direction

        -- if next coord is not blocked, can move in direction
        if not level:isBlocked(next_coord) then
            return Move(level, entity, next_coord)            
        end

        -- direction was blocked - if blocked by enemy entity perform a melee attack
        target = tryGetEnemy(level, next_coord)
        if target ~= nil then
            return Attack(level, entity, target)
        end

        -- blocked by a wall, so stop moving
        return nil
    end

    return setmetatable({
        -- methods
        getAction = getAction,
    }, Mouse)
end

return setmetatable(Mouse, {
    __call = function(_, ...) return Mouse.new(...) end,
})
