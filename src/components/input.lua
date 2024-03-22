--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Input = {}

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
        error('invalid direction "' .. tostring(dir) .. '"')
    end
end

function Input.new(entity, def)
    local is_busy = false

    update = function(self, dt, level)
        if is_busy then return end

        -- try move
        local dir = Direction.NONE
        if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
            dir = Direction.W
        elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            dir = Direction.E
        elseif love.keyboard.isDown('up') or love.keyboard.isDown('w') then
            dir = Direction.N
        elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
            dir = Direction.S
        end

        local next_coord = entity.coord + dir

        -- ensure entity can move to next coord
        if next_coord == entity.coord then return end
        if level:isBlocked(next_coord) then return end 

        local prev_coord = entity.coord:clone()
        level:setBlocked(prev_coord, false)
        level:setBlocked(next_coord, true)

        if self.dir ~= dir then
            updateAnimation(entity, def, dir)
            self.dir = dir
        end

        -- move possible, so start move animation
        is_busy = true
        Timer.tween(0.2, entity, { coord = next_coord }, 'linear', function()
            entity.coord = next_coord
            is_busy = false
        end)

        level:moveCamera(next_coord, 0.2)
    end

    -- set initial animation
    updateAnimation(entity, def, Direction.S)

    return setmetatable({
        dir         = nil,
        -- methods
        update      = update,
    }, Input)
end

return setmetatable(Input, { __call = function(_, ...) return Input.new(...) end })
