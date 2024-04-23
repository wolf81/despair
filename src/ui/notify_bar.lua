--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, mceil, mmin, mmax = math.floor, math.ceil, math.min, math.max

local NotifyBar = {}

local FADE_DURATION = 0.2
local MARGIN        = 10

local function shallowClone(tbl)
    local clone = {}
    for k, v in pairs(tbl) do
        clone[k] = v
    end
    return clone
end

local function newBackground(w, h)
    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function() 
        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.rectangle('fill', 0, 0, w, h)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.rectangle('line', 0.5, 0.5, w - 1, h - 1)
    end)
    return canvas
end

NotifyBar.new = function()
    -- a notification queue, as we will only show a single notification at any time
    local notifications = {}

    -- the current notification
    local notification = nil

    -- a background image to show behind the notification text
    local background = nil

    local show = function(self, message)
        if notification and notification.message == message then
            -- if a new message arrives that is same as current message being shown ...
            if #notifications == 0 then
                -- requeue the message if notification list is empty
                table.insert(notifications, shallowClone(notification))
            elseif #notifications > 0 and notifications[#notifications].message ~= message then
                -- if notification list is not empty, only requeue if last message doesn't match 
                -- current message
                table.insert(notifications, shallowClone(notification))
            end 

            return 
        end

        -- calculate a rectangle, large enough to fit the text, including some margin
        local spacing = FONT:getHeight() - FONT:getLineHeight()
        local max_w = WINDOW_W - STATUS_PANEL_W - MARGIN * 2
        local line_h = FONT:getHeight() * FONT:getLineHeight()

        local w = FONT:getWidth(message)
        local lines = mceil(w / max_w)
        local is_half_line = w < (max_w / 2)
        local h = lines * line_h + MARGIN * 2 - spacing
        w = lines > 1 and max_w or mmin(w + MARGIN * 2, max_w)
        local x = mfloor((max_w - w) / 2) + MARGIN
        local y = mfloor(WINDOW_H - ACTION_BAR_H - h) - MARGIN

        background = newBackground(w, h)

        table.insert(notifications, { 
            message     = message, 
            duration    = lines * 1.0, 
            alpha       = 0.0,
            frame       = Rect(x, y, w, h),
        })
    end

    local update = function(self, dt)
        if notification or #notifications == 0 then return end

        notification = table.remove(notifications, 1)

        -- fade in, show message, fade out
        Timer.tween(FADE_DURATION, notification, { alpha = 1.0 }, 'linear', function() 
            Timer.after(notification.duration, function()
                Timer.tween(FADE_DURATION, notification, { alpha = 0.0 }, 'linear', function() 
                    notification = nil
                end)
            end)
        end)
    end

    local draw = function(self)
        if not notification then return end

        local x, y, w, h = notification.frame:unpack()
        love.graphics.setColor(1.0, 1.0, 1.0, notification.alpha)
        love.graphics.draw(background, x, y)
        love.graphics.printf(notification.message, x, y + MARGIN + 1, w, 'center')
    end

    return setmetatable({
        -- methods
        update  = update,
        show    = show,
        draw    = draw,
    }, NotifyBar)
end

return setmetatable(NotifyBar, {
    __call = function(_, ...) return NotifyBar.new(...) end,
})
