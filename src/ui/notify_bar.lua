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

    local handle = nil

    -- the current notification
    local notification = nil

    local update = function(self, dt)
        if notification or #notifications == 0 then return end

        notification = table.remove(notifications, 1)

        -- fade in, show message, fade out
        handle = Timer.tween(FADE_DURATION, notification, { alpha = 1.0 }, 'linear', function() 
            handle = Timer.after(notification.duration, function()
                self:dismiss()
            end)
        end)
    end

    local draw = function(self)
        if not notification then return end

        local x, y, w, h = notification.frame:unpack()
        love.graphics.setColor(1.0, 1.0, 1.0, notification.alpha)
        love.graphics.draw(notification.background, x, y)
        love.graphics.printf(notification.message, x, y + MARGIN + 1, w, 'center')
    end

    local show = function(self, message)
        if notification and notification.message ~= message then
            if handle then 
                Timer.cancel(handle) 
                handle = nil
                notification = nil
            end
        end

        if not notification or notification.message ~= message then
            -- calculate a rectangle, large enough to fit the text, including some margin
            local spacing = FONTS['default']:getHeight() - FONTS['default']:getLineHeight()
            local max_w = WINDOW_W - STATUS_PANEL_W - MARGIN * 2
            local line_h = FONTS['default']:getHeight() * FONTS['default']:getLineHeight()

            local w = FONTS['default']:getWidth(message)
            local lines = mceil(w / max_w)
            local is_half_line = w < (max_w / 2)
            local h = lines * line_h + MARGIN * 2 - spacing
            w = lines > 1 and max_w or mmin(w + MARGIN * 2, max_w)
            local x = mfloor((max_w - w) / 2) + MARGIN
            local y = mfloor(WINDOW_H - ACTION_BAR_H - h) - MARGIN

            table.insert(notifications, { 
                background  = newBackground(w, h),
                message     = message, 
                duration    = lines * 1.5, 
                alpha       = 0.0,
                frame       = Rect(x, y, w, h),
            })
        end
    end

    local dismiss = function(self)
        if not notification then return end

        if handle then Timer.cancel(handle) end

        handle = Timer.tween(FADE_DURATION, notification, { alpha = 0.0 }, 'linear', function() 
            notification = nil
            handle = nil
        end)        
    end

    return setmetatable({
        -- methods
        update  = update,
        dismiss = dismiss,
        show    = show,
        dismiss = dismiss,
        draw    = draw,
    }, NotifyBar)
end

return setmetatable(NotifyBar, {
    __call = function(_, ...) return NotifyBar.new(...) end,
})
