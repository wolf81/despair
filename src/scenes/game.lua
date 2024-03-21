local Game = {}

Game.new = function()
    local dungeon = Dungeon()

    local update = function(self, dt) dungeon:update(dt) end

    local draw = function(self) dungeon:draw() end

    return setmetatable({
        -- methods
        update  = update,
        draw    = draw,
    }, Game)
end

return setmetatable(Game, { 
    __call = function(_, ...) return Game.new(...) end,
})
