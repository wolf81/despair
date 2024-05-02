local mfloor = math.floor

local NewPlayer = {}

local function generateButtonTexture(title)
    return TextureGenerator.generateButtonTexture(120, 48, title)
end

local function onSelectGender()
    Gamestate.push(ChooseOption(
        'CHOOSE GENDER', 
        function(gender) print('selected', gender) end,
        'Male', 'Female'))
end

local function onSelectRace()
    Gamestate.push(ChooseOption(
        'CHOOSE RACE', 
        function(race) print('selected', race) end,
        'Human', 'Elf', 'Dwarf', 'Halfling'))
end

local function onSelectClass()
    Gamestate.push(ChooseOption(
        'CHOOSE CLASS', 
        function(class) print('selected', class) end,
        'Fighter', 'Mage', 'Cleric', 'Rogue'))
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
                UI.makeButton(onSelectGender,  generateButtonTexture('GENDER')),
                UI.makeButton(onSelectRace, generateButtonTexture('RACE')),
                UI.makeButton(onSelectClass, generateButtonTexture('CLASS')),
                UI.makeButton(onSelectStats, generateButtonTexture('STATS')),
                UI.makeButton(onSelectSkills, generateButtonTexture('SKILLS')),
                UI.makeButton(onChangeName, generateButtonTexture('NAME')),
                UI.makeButton(onChangePortrait, generateButtonTexture('PORTRAIT')),
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
