--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local LevelUp = {}

local function getFrame(background)
    local w, h = background:getDimensions()
    local x = (WINDOW_W - w - STATUS_PANEL_W) / 2
    local y = (WINDOW_H - h - ACTION_BAR_H) / 2
    return Rect(x, y, w, h)
end

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

local function generateImageButtonTexture(quad_idx)
    return TextureGenerator.generateImageButtonTexture(24, 24, quad_idx)
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
    local stats = player:getComponent(Stats)

    local next_level = class:getLevel() + 1

    local preview = class:levelUp(true)

    local background = TextureGenerator.generatePanelTexture(240, 220)
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
        table.insert(lines, 
            'Damage:    ' .. StringHelper.padRight('+' .. tostring(preview.dmg_bonus), STR_PAD))
    end

    local dismiss = function()
        overlay:fadeOut(Gamestate.pop) 
    end

    local accept = function()
        class:levelUp()
        dismiss()
    end

    local acceptButton = UI.makeButton(accept, generateTextButtonTexture('ACCEPT'))
    acceptButton.widget:setEnabled(stats:getPoints() == 0)

    local assignStat = function()
        local str = stats:getValue('str')
        local dex = stats:getValue('dex')
        local mind = stats:getValue('mind')
        local points = stats:getPoints()
        
        Gamestate.push(AssignPoints(
            'ASSIGN STATS',
            function(str_, dex_, mind_) 
                stats:assignPoints(str_ - str, 'str')
                stats:assignPoints(dex_ - dex, 'dex')
                stats:assignPoints(mind_ - mind, 'mind')
                acceptButton.widget:setEnabled(stats:getPoints() == 0)
            end,
            {
                { key = 'Strength',  value = str,  min = str,  max = str + points  },                
                { key = 'Dexterity', value = dex,  min = dex,  max = dex + points  },
                { key = 'Mind',      value = mind, min = mind, max = mind + points },
            },
        points))        
    end

    local text = table.concat(lines, '\n')

    local controls = {
        UI.makeLabel('LEVEL UP', { 1.0, 1.0, 1.0, 1.0 }, 'center', 'start'),
        UI.makeTextview(text),
        tidy.HStack({
            UI.makeLabel('Assign stat point', { 1.0, 1.0, 1.0, 1.0 }, 'left', 'center'),
            UI.makeFlexSpace(),
            UI.makeButton(assignStat, generateImageButtonTexture(379)),
        }),
        tidy.HStack({
            UI.makeButton(dismiss, generateTextButtonTexture('CLOSE')),
            UI.makeFlexSpace(),
            acceptButton,
        }),
    }

    if stats:getPoints() == 0 then table.remove(controls, 3) end

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), tidy.Stretch(1), controls)
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
    end

    local leave = function(self, to)
        game = nil
    end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then 
            dismiss()
        end
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        if Gamestate.current() == self and not frame:contains(mx, my) then
            dismiss()
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
