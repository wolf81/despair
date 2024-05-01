--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Scroller = {}

Scroller.new = function()
    local frame = Rect(0)

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 0.5)
        love.graphics.rectangle('fill', x, y, w, h)

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.rectangle('line', x, y, w, h)
    end

    local update = function(self, dt)
        -- body
    end

    local setFrame = function(self, x, y, w, h)
        frame = Rect(x, y, w, h)
    end

    local getFrame = function(self) return frame:unpack() end
    
    return setmetatable({
        -- methods 
        draw        = draw,
        update      = update,
        getFrame    = getFrame,
        setFrame    = setFrame,
    }, Scroller)
end

return setmetatable(Scroller, {
    __call = function(_, ...) return Scroller.new(...) end,
})
