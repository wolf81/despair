local ChooseItem = {}

ChooseItem.new = function(player, items, button)
    local game = nil

    local item_bar = ItemBar(items)
    local bar_w, bar_h = item_bar:getSize()
    local btn_x, btn_y, btn_w, btn_h = button:getFrame()
    local bar_x = btn_x - bar_w / 2 + (bar_w / #items / 2) 
    local bar_y = btn_y - bar_h - 1
    item_bar:setFrame(bar_x, bar_y, bar_w, bar_h)

    local enter = function(self, from)
        game = from

        game:showOverlay()

        button:setSelected(true)
    end

    local leave = function(self, to)
        game:hideOverlay()

        button:setSelected(false)

        game = nil
    end

    local draw = function(self)
        game:draw()

        item_bar:draw()
    end

    local update = function(self, dt)
        -- body
    end

    local keyReleased = function(self, key, scancode)
        if key == "escape" then
            Gamestate.pop()
        end
    end
    
    return setmetatable({
        -- methods
        draw        = draw,
        enter       = enter,
        leave       = leave,
        update      = update,
        keyReleased = keyReleased,
    }, ChooseItem)
end

return setmetatable(ChooseItem, {
    __call = function(_, ...) return ChooseItem.new(...) end,
})
