local Sleep = {}

local FADE_DURATION = 0.5

local function getMissingHealth(player)
    local health = player:getComponent(Health)
    local current, total = health:getValue()
    return total - current
end

Sleep.new = function(player)
    -- recover health over time (turns)
    local health = player:getComponent(Health)
    assert(health ~= nil, 'missing component: "Health"')

    local control = player:getComponent(Control)
    assert(control ~= nil, 'missing component: "Control"')

    local game, did_enter_sleep, did_finish_sleep = nil, false, false

    local background = {
        texture = TextureGenerator.generateColorTexture(
            WINDOW_W - STATUS_PANEL_W, 
            WINDOW_H - ACTION_BAR_H, 
            { 0.0, 0.0, 0.0, 1.0 }),
        alpha = 0.0,
    }

    local draw = function(self)
        game:draw()

        love.graphics.setColor(1.0, 1.0, 1.0, background.alpha)
        love.graphics.draw(background.texture)
    end

    local update = function(self, dt)
        game:update(dt)

        if did_finish_sleep or not did_enter_sleep then return end

        if not player:getComponent(Control):isSleeping() then
            did_finish_sleep = true
            -- start 'exit sleep' animation
            Timer.tween(FADE_DURATION, background, { alpha = 0.0 }, 'linear', function() 
                Gamestate.pop()
            end)
        end
    end

    local enter = function(self, from)
        game = from

        control:setEnabled(false)
        game:setActionsEnabled(false)

        -- 8 hours needed to fully sleep
        -- 30 AP == how many hours?
        -- 1 turn == 6 seconds (30 AP?)
        -- 1 move then, could be 5 AP?

        -- 1 minute = 10 turns
        -- 1 hour = 600 turns
        -- 8 hours = 4800 turns

        -- movement speed based on 1 round (10 turns)
        -- so movement speed 30 means 6 tiles in 10 turns about 0.6

        -- we need to compress turns, cause waiting 4800 turns is too long
        -- maybe divide by 100, increase monster spawn chance by 100 (?)
        
        local sleep_turns = 48
        control:sleep(sleep_turns)

        local missing = getMissingHealth(player)        

        -- start 'enter sleep' animation
        Timer.tween(FADE_DURATION, background, { alpha = 1.0 }, 'linear', function()
            control:setEnabled(true)
            did_enter_sleep = true
        end)
    end

    local leave = function(self, to)
        control:setEnabled(true)
        game:setActionsEnabled(true)

        game = nil
    end

    return setmetatable({
        -- methods
        draw    = draw,
        enter   = enter,
        leave   = leave,
        update  = update,
    }, Sleep)
end

return setmetatable(Sleep, {
    __call = function(_, ...) return Sleep.new(...) end,
})
