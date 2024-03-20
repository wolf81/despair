--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Intellect = {}

local function updateAnimation(entity, def, dir)
    local visual = entity:getComponent(Visual)

    if dir == Direction.N then
        visual.anim = Animation.loop(def['anim_n'])
    elseif dir == Direction.E then
        visual.anim = Animation.loop(def['anim_e'])    
    elseif dir == Direction.W then
        visual.anim = Animation.loop(def['anim_w'])    
    elseif dir == Direction.S or dir == Direction.NONE then
        visual.anim = Animation.loop(def['anim_s'])
    else
        error('invalid direction "' .. dir .. '"')
    end
end

local function getRandomDirection()
    local dirs = { Direction.N, Direction.E, Direction.S, Direction.W }
    return dirs[math.random(#dirs)]
end

function Intellect.new(entity, def)
    local is_busy = false

    update = function(self, dt, game)
        if is_busy then return end

        local dir = getRandomDirection()
        local next_coord = entity.coord + dir

        -- ensure entity can move to next coord
        if next_coord == entity.coord then return end
        if game:isBlocked(next_coord) then return end 

        local prev_coord = entity.coord:clone()
        game:setBlocked(next_coord, true)

        if self.dir ~= dir then
            updateAnimation(entity, def, dir)
            self.dir = dir
        end

        -- move possible, so start move animation
        is_busy = true
        Timer.tween(0.5, entity, { coord = next_coord }, 'linear', function() 
            entity.coord = next_coord
            game:setBlocked(prev_coord, false)
            is_busy = false
        end)
    end

    -- set initial animation
    updateAnimation(entity, def, Direction.S)

    return setmetatable({
        -- properties
        dir    = nil,
        -- methods
        update = update,
    }, Intellect)
end

return setmetatable(Intellect, { __call = function(_, ...) return Intellect.new(...) end })
