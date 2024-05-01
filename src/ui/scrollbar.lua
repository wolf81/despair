--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Scrollbar = {}

Scrollbar.new = function()
    local frame = Rect(0)

    local direction = 'none' -- 'up', 'down'

    local is_visible = true

    local up_button, dn_button = ScrollbarButton('up'), ScrollbarButton('down')

    local scroller = Scroller()

    local draw = function(self)
        if not is_visible then return end

        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 0.3)
        love.graphics.rectangle('fill', x, y, w, h)

        up_button:draw()
        dn_button:draw()
        scroller:draw()

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.rectangle('line', x, y, w, h)
    end

    local update = function(self, dt)
        if not is_visible then return end

        up_button:update(dt)
        dn_button:update(dt)
        scroller:update(dt)

        direction = 'none'
        if up_button:isPressed() then direction = 'up' end
        if dn_button:isPressed() then direction = 'down' end
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 

        up_button:setFrame(x, y, w, w)
        dn_button:setFrame(x, y + h - w, w, w)
        scroller:setFrame(x, y + w, w, w)
    end

    local getFrame = function(self) return frame end

    local getDirection = function(self) return direction end

    local setVisible = function(self, flag) is_visible = (flag == true) end

    local setScrollAmount = function(self, value)
        local x, y, w, h = frame:unpack()

        scroller:setFrame(x, y + w + (h - w * 3) * value, w, w)
    end

    return setmetatable({
        -- methods
        draw                = draw,
        update              = update,
        getFrame            = getFrame,
        setFrame            = setFrame,
        setVisible          = setVisible,
        getDirection        = getDirection,
        setScrollAmount     = setScrollAmount,
    }, Scrollbar)
end

return setmetatable(Scrollbar, {
    __call = function(_, ...) return Scrollbar.new(...) end,
})
