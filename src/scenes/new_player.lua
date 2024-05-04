local mfloor = math.floor

local NewPlayer = {}

local function generateButtonTexture(title)
    return TextureGenerator.generateButtonTexture(120, 48, title)
end

local function getStatValues()
    -- TODO: add race bonus

    local stats = {}
    for i = 1, 3 do
        -- roll 1d6, store 4 values
        local values = {}
        for i = 1, 4 do
            table.insert(values, ndn.dice('1d6').roll())
        end
        
        -- sort values descending
        table.sort(values, function(a, b) return a > b end)

        -- use the 3 highest values as stat value
        local value = 0
        for j = 1, 3 do value = value + values[j] end
        
        table.insert(stats, value)
    end
    
    return stats
end

NewPlayer.new = function()
    local image = TextureGenerator.generatePanelTexture(120, 48)

    local lines = {}
    
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

    local stats = getStatValues()
    local function onSelectStats()
        Gamestate.push(AssignPoints(
            'ASSIGN STATS',
            {
                { key = 'Strength',         value = stats[1] },
                { key = 'Dexterity',        value = stats[2] },
                { key = 'Mind',             value = stats[3] },
            }, 
            3))
    end

    local function onSelectSkills()
        Gamestate.push(AssignPoints(
            'ASSIGN SKILLS', 
            {
                { key = 'Physical',         value = 1 },
                { key = 'Subterfuge',       value = 1 },
                { key = 'Knowledge',        value = 1 },
                { key = 'Communication',    value = 1 },
                { key = 'Survival',         value = 1 },
            }, 
            0))
    end

    local function onChangeName()
        print('change name')
    end

    local function onChangePortrait()
        print('change portrait')
    end

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
