--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mmin, mmax = math.min, math.max

local Chooser = {}

local DISABLED_ALPHA = 0.7
local SCROLLBAR_W = 20
local SCROLL_SPEED = 10
local ITEM_H = 32

Chooser.new = function(...)
    local options = {...}

    local background = nil
    local frame = Rect(0)
    local is_enabled = true

    local oy = 0

    local items = {}
    for _, option in ipairs(options) do
        table.insert(items, ChooserItem(option))
    end

    local scrollbar = Scrollbar()

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, (is_enabled and 1.0 or DISABLED_ALPHA))
        love.graphics.draw(background, x, y)

        love.graphics.setScissor(x + 1, y + 1, w - 2, h - 2)
        love.graphics.push()
        love.graphics.translate(0, oy)
        for _, item in ipairs(items) do item:draw() end
        love.graphics.pop()

        scrollbar:draw()

        love.graphics.setScissor()
    end

    local update = function(self, dt)
        if not is_enabled then return end

        for _, item in ipairs(items) do 
            item:update(dt) 
            if item:wasPressed() then
                print('pressed', item:getText())
            end
        end

        scrollbar:update(dt)

        local scroll_direction = scrollbar:getDirection()
        if scroll_direction == 'up' then
            oy = mmax(oy - SCROLL_SPEED * dt, 0)
        elseif scroll_direction == 'down' then
            oy = mmax(oy + SCROLL_SPEED * dt, #items * ITEM_H)
        end
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 

        background = TextureGenerator.generateBorderTexture(w, h)

        local item_y, item_w = y, w - SCROLLBAR_W

        for _, item in ipairs(items) do
            item:setFrame(x, item_y, item_w, ITEM_H)
            item_y = item_y + ITEM_H
        end

        scrollbar:setFrame(x + w - SCROLLBAR_W, y, SCROLLBAR_W, h)
        scrollbar:setEnabled(#items * ITEM_H > h)
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
