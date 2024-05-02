--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin, mmax = math.min, math.max

local Chooser = {}

local DISABLED_ALPHA = 0.7
local SCROLLBAR_W = 20
local SCROLL_SPEED = 150
local ITEM_H = 32

Chooser.new = function(fn, ...)
    assert(fn ~= nil, 'missing argument: "fn"')
    assert(type(fn) == 'function', 'invalid argument for "fn", expected: "function"')

    local options = {...}

    local background = nil
    local frame = Rect(0)
    local is_enabled = true

    local items = {}
    for _, option in ipairs(options) do
        table.insert(items, ChooserItem(option))
    end

    local content_h = #items * ITEM_H
    local content_y = 0

    local scrollbar = Scrollbar()

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, (is_enabled and 1.0 or DISABLED_ALPHA))
        love.graphics.draw(background, x, y)

        love.graphics.setScissor(x + 1, y + 1, w - 2, h - 2)
        love.graphics.push()
        love.graphics.translate(0, -content_y)
        for _, item in ipairs(items) do item:draw() end
        love.graphics.pop()

        scrollbar:draw()

        love.graphics.setScissor()
    end

    local update = function(self, dt)
        if not is_enabled then return end

        local h = select(2, frame:getSize())

        scrollbar:update(dt)

        local scroll_direction = scrollbar:getDirection()
        if scroll_direction == 'up' then
            content_y = mmax(content_y - SCROLL_SPEED * dt, 0)
        elseif scroll_direction == 'down' then
            content_y = mmin(content_y + SCROLL_SPEED * dt, content_h - h)
        end

        scrollbar:setScrollAmount(content_y / (content_h - h))

        local mx, my = love.mouse.getPosition()
        mx, my = mx / UI_SCALE, my / UI_SCALE

        for _, item in ipairs(items) do
            local item_frame = Rect(item:getFrame())
            item:setHighlighted(item_frame:contains(mx, my + content_y))

            item:update(dt) 
            if item:wasPressed() then fn(item) end
        end
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 

        background = TextureGenerator.generateBorderTexture(w, h)

        local item_y, item_w = y, w - SCROLLBAR_W

        if content_h <= h then
            item_w = w
        end

        local show_scrollbar = content_h > h

        for _, item in ipairs(items) do
            item:setFrame(x, item_y, item_w, ITEM_H)
            item_y = item_y + ITEM_H

            if show_scrollbar then
                item:setTextOffset(SCROLLBAR_W / 2, 0)
            end
        end

        scrollbar:setFrame(x + w - SCROLLBAR_W, y, SCROLLBAR_W, h)
        scrollbar:setVisible(show_scrollbar)
    end

    local getFrame = function(self) return frame end

    local getSize = function(self) return frame:getSize() end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        setFrame    = setFrame,
        getFrame    = getFrame,
    }, Chooser)
end

return setmetatable(Chooser, {
    __call = function(_, ...) return Chooser.new(...) end,
})
