--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local LevelUp = {}

local function getFrame(background)
    local w, h = background:getDimensions()
    local x = (WINDOW_W - w) / 2
    local y = (WINDOW_H - h) / 2
    return Rect(x, y, w, h)
end

local function getCheckImage()
    local texture = TextureCache:get('uf_interface')
    local quad = QuadCache:get('uf_interface')[384]
    local quad_w, quad_h = select(3, quad:getViewport())

    local background = TextureGenerator.generatePanelTexture(24, 24)
    local background_w, background_h = background:getDimensions()
    local canvas = love.graphics.newCanvas(24, 24)

    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, 0, 0)
        local x, y = mfloor((background_w - quad_w) / 2), mfloor((background_h - quad_h) / 2)
        love.graphics.draw(texture, quad, x, y)
    end)

    return love.graphics.newImage(canvas:newImageData())
end

LevelUp.new = function(player)
    local game = nil

    local class = player:getComponent(Class)
    local health = player:getComponent(Health)

    local next_level = class:getLevel() + 1

    local preview = class:levelUp(true)

    local background = TextureGenerator.generateParchmentTexture(220, 160)
    local frame = getFrame(background)

    local overlay = Overlay()

    local STR_PAD = 10

    local lines = {
        'LEVEL ' .. preview.level,
        '',
        'Hitpoints: ' .. StringHelper.padRight('+' .. tostring(preview.hp_gain), STR_PAD),
        'Attack:    ' .. StringHelper.padRight('+' .. tostring(preview.att_bonus), STR_PAD),
    }

    if preview.dmg_bonus then
        table.insert(lines, 'Damage:    ' .. StringHelper.padRight('+' .. tostring(preview.dmg_bonus), STR_PAD))
    end

    local text = table.concat(lines, '\n')

    local handles = {}

    local layout = tidy.Border(tidy.Margin(20), {
        tidy.VStack({
            UI.makeLabel(text, { 0.0, 0.0, 0.0, 0.7 }),
            UI.makeFlexSpace(),
            tidy.HStack(tidy.MinSize(24), {
                UI.makeFlexSpace(),
                UI.makeButton('accept', getCheckImage())
            }),
        })
    }):setFrame(frame:unpack())

    local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local draw = function(self)
        game:draw()
        overlay:draw()

        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        for e in layout:eachElement() do e.widget:draw() end
    end

    local enter = function(self, from)
        assert(getmetatable(from) == Game, 'invalid argument for "from", expected: "Game"')

        game = from
        overlay:fadeIn()

        -- TODO: update player stats for new level
        handle = Signal.register('accept', function() 
            class:levelUp()
            Gamestate.pop() 
        end)
    end

    local leave = function(self, to)
        game = nil

        Signal.remove('accept', handle)
    end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then 
            overlay:fadeOut(Gamestate.pop) 
        end
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        if Gamestate.current() == self and not frame:contains(mx, my) then
            overlay:fadeOut(Gamestate.pop) 
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
