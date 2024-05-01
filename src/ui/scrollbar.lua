--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Scrollbar = {}

Scrollbar.new = function()
    local frame = Rect(0)

    local direction = 'none' -- 'up', 'down'

    local enabled = true

    local up_button, dn_button = ScrollbarButton('up'), ScrollbarButton('down')

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 0.3)
        love.graphics.rectangle('fill', x, y, w, h)

        up_button:draw()
        dn_button:draw()

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.rectangle('line', x, y, w, h)
    end

    local update = function(self, dt) 
        direction = 'none'

        up_button:update(dt)
        dn_button:update(dt)

        if love.mouse.isDown(1) then
            local x, y, w, h = frame:unpack()

            local mx, my = love.mouse.getPosition()
            -- is_highlighted = frame:contains(mx / UI_SCALE, my / UI_SCALE)

            if my > y and my < y + w then
                direction = 'up'
            end

            if my > y + h - w and my < y + h then
                direction = 'down'
            end
        end
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 

        up_button:setFrame(x, y, w, w)
        dn_button:setFrame(x, y + h - w, w, w)
    end

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
