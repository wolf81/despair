--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local LevelUp = {}

local function getFrame(background)
    local w, h = background:getDimensions()
    local x = (WINDOW_W - w) / 2
    local y = (WINDOW_H - h) / 2
    return Rect(x, y, w, h)
end

LevelUp.new = function(player)
    local game = nil

    local exp_level = player:getComponent(ExpLevel)
    local next_level = exp_level:getLevel() + 1

    local background = TextureGenerator.generateParchmentTexture(220, 160)
    local frame = getFrame(background)

    -- TODO: probably an entity Class component should be responsible for calculating hp gain
    -- hp gain should be cached for the current level, so repeatedly opening this scene will show
    -- same hp gain
    -- TODO: it should be possible to 'seed' ndn or provide your own rng or integrate prng
    local hp_gain = ndn.dice('1d6').roll()

    local STR_PAD = 6

    local text = StringHelper.concat({
        'Level:         ' .. StringHelper.padRight(tostring(next_level), STR_PAD),
        '',
        'hitpoint gain: ' .. StringHelper.padRight(tostring(hp_gain), STR_PAD),
    }, '\n')

    local layout = tidy.Border(tidy.Margin(20), {
        tidy.VStack({
            UI.makeLabel(text, { 0.0, 0.0, 0.0, 0.7 }),
        })
    })
    layout:setFrame(frame:unpack())
    for e in layout:eachElement() do
        e.widget:setFrame(e.rect:unpack())
    end

    local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local draw = function(self)
        game:draw()

        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        for e in layout:eachElement() do e.widget:draw() end
    end

    local enter = function(self, from)
        assert(getmetatable(from) == Game, 'invalid argument for "from", expected: "Game"')

        game = from
        game:showOverlay()
    end

    local leave = function(self, to)
        game:hideOverlay()
        game = nil
    end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            Gamestate.pop()
        end
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        if Gamestate.current() == self and not frame:contains(mx, my) then
            Gamestate.pop()
        end
    end
        
    return setmetatable({
        -- methods
        mouseReleased   = mouseReleased,
        keyReleased     = keyReleased,
        update          = update,
        enter           = enter,
        leave           = leave,
        draw            = draw,
    }, LevelUp)
end

return setmetatable(LevelUp, {
    __call = function(_, ...) return LevelUp.new(...) end,
})
