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

    update = function(self, dt, game)
        if is_busy then return end

        -- try interact
        if love.keyboard.isDown('e') then
            local x1, x2 = entity.coord.x - 1, entity.coord.x + 1
            local y1, y2 = entity.coord.y - 1, entity.coord.y + 1

            for y = y1, y2 do
                for x = x1, x2 do
                    -- TODO: skip self
                    -- maybe should have a getEntity method that accepts a filter function?
                    local entity, interactable = game:getEntityWithComponent(x, y, Interactable)

                    if interactable == nil then goto continue end

                    interactable:interact(game, entity)

                    ::continue::
                end
            end
        end

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
        if dir == Direction.NONE then return end
        if game:isBlocked(next_coord) then return end 

        local prev_coord = entity.coord:clone()
        game:setBlocked(next_coord, true)

        if self.dir ~= dir then
            updateAnimation(entity, def, dir)
            self.dir = dir
        end

        -- move possible, so start move animation
        is_busy = true
        Timer.tween(0.2, entity, { coord = next_coord }, 'linear', function()
            entity.coord = next_coord
            game:setBlocked(prev_coord, false)
            is_busy = false
        end)

        game:moveCamera(next_coord, 0.2)

        -- if we can enter room, update visuals
        local door = game:getEntity(next_coord.x, next_coord.y, function(entity) 
            return entity.type == 'door' 
        end)
        if door ~= nil then
            game:enterRoom(door.coord.x, door.coord.y)
        end
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
