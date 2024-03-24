local Control = {}

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

Control.new = function(entity, def, input_type)
    assert(input_type ~= nil, 'missing parameter "input_type"')
    
    local update = function(self, dt)
        -- body
    end

    local getAction = function(self, level) 
        local direction = input_type:getInput(level)
        if direction ~= nil then
            level:setBlocked(entity.coord, false)
            local next_coord = entity.coord + direction
            level:setBlocked(next_coord, true)
            return Move(entity, next_coord)
        end

        return nil
    end

    -- set initial animation
    updateAnimation(entity, def, Direction.S)

    return setmetatable({        
        -- methods
        update      = update,
        getAction   = getAction,
    }, Control)
end

return setmetatable(Control, {
    __call = function(_, ...) return Control.new(...) end,
})