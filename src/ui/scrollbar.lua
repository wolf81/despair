--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Scrollbar = {}

Scrollbar.new = function()
    local frame = Rect(0)

    local direction = 'none' -- 'up', 'down'

    local enabled = true

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 0.5)
        love.graphics.rectangle('fill', x, y, w, h)
    end

    local update = function(self, dt) 

    end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame end

    local getDirection = function(self) return direction end

    local setEnabled = function(self, flag) enabled = (flag == true) end

    return setmetatable({
        -- methods
        draw            = draw,
        update          = update,
        getFrame        = getFrame,
        setFrame        = setFrame,
        setEnabled      = setEnabled,
        getDirection    = getDirection,
    }, Scrollbar)
end

return setmetatable(Scrollbar, {
    __call = function(_, ...) return Scrollbar.new(...) end,
})
