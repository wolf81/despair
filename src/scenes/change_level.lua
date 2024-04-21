local ChangeLevel = {}

ChangeLevel.new = function()
    local game = nil

    -- TODO:
    -- 1. darken all area around player, keep player visible
    -- 2. change level
    -- 3. lighten up area around player

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        game:draw()
    end

    local enter = function(self, from)
        game = from
    end

    local leave = function(self, to)
        game = nil
    end

    return setmetatable({
    }, ChangeLevel)
end

return setmetatable(ChangeLevel, {
    __call = function(_, ...) return ChangeLevel.new(...) end,
})
