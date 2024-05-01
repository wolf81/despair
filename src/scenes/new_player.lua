local mfloor = math.floor

local NewPlayer = {}

local function generateButtonTexture(image, text) 
    local w, h = image:getDimensions()

    local text_w, text_h = FONT:getWidth(text), FONT:getHeight()
    local text_x, text_y = mfloor((w - text_w) / 2), mfloor((h - text_h) / 2)

    local canvas = love.graphics.newCanvas(w, h)
    canvas:renderTo(function()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
        love.graphics.draw(image, 0, 0)
        love.graphics.print(text, text_x, text_y)
    end)

    return canvas
end

local function onSelectGender()
    Gamestate.push(ChooseOption('CHOOSE GENDER', 'Male', 'Female'))
end

local function onSelectRace()
    Gamestate.push(ChooseOption('CHOOSE RACE', 'Human', 'Elf', 'Dwarf', 'Halfling'))
end

local function onSelectClass()
    Gamestate.push(ChooseOption('CHOOSE CLASS', 'Fighter', 'Mage', 'Cleric', 'Rogue'))
end

local function onSelectStats()
    print('adjust stats')
end

local function onSelectSkills()
    print('choose skills')
end

local function onChangeName()
    print('change name')
end

local function onChangePortrait()
    print('change portrait')
end

NewPlayer.new = function()
    local image = TextureGenerator.generatePanelTexture(120, 48)

    local layout = tidy.Border(tidy.Margin(180, 10, 180, 10), {
        tidy.HStack(tidy.Spacing(10), {
            tidy.VStack(tidy.MinSize(0, 120), tidy.Spacing(2), {
                UI.makeButton(onSelectGender, generateButtonTexture(image, 'GENDER')),
                UI.makeButton(onSelectRace, generateButtonTexture(image, 'RACE')),
                UI.makeButton(onSelectClass, generateButtonTexture(image, 'CLASS')),
                UI.makeButton(onSelectStats, generateButtonTexture(image, 'STATS')),
                UI.makeButton(onSelectSkills, generateButtonTexture(image, 'SKILLS')),
                UI.makeButton(onChangeName, generateButtonTexture(image, 'NAME')),
                UI.makeButton(onChangePortrait, generateButtonTexture(image, 'PORTRAIT')),
            }),
            UI.makeParchment('...'),
        }),
    }):setFrame(0, 0, WINDOW_W, WINDOW_H)

    local draw = function(self)
        love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
        love.graphics.rectangle('fill', 0, 0, WINDOW_W, WINDOW_H)

        for e in layout:eachElement() do e.widget:draw() end
    end

    local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local enter = function(self, from)
        -- body
    end

    local leave = function(self, to)
        -- body
    end

    local keyReleased = function(self, key, scancode)        
        if key == 'i' then Signal.emit('inventory') end

        if Gamestate.current() == self and key == 'escape' then
            love.event.quit()
        end
    end

    return setmetatable({
        -- methods
        draw        = draw,
        enter       = enter,
        leave       = leave,
        update      = update,
        keyReleased = keyReleased,
    }, NewPlayer)
end

return setmetatable(NewPlayer, {
    __call = function(_, ...) return NewPlayer.new(...) end,
})
