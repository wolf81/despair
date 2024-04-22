--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local FlexSpace = {}

FlexSpace.new = function()
    local frame = Rect(0)

    local update = function(self, dt) end

    local draw = function(self) end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end 

    local getFrame = function(self) return frame:unpack() end

    return setmetatable({
        -- methods        
        getFrame    = getFrame,
        setFrame    = setFrame,   
        update      = update,
        draw        = draw,
    }, FlexSpace)
end

return setmetatable(FlexSpace, {
    __call = function(_, ...) return FlexSpace.new(...) end,
})
