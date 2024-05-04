local mfloor = math.floor

local NewPlayer = {}

local function generateButtonTexture(title)
    return TextureGenerator.generateButtonTexture(120, 48, title)
end

local function getSkillValues(race)
    local phys = {
        value = 1,
        min = 1,
        max = 1,
    }

    local subt = {
        value = 1,
        min = 1,
        max = 1,        
    }

    local know = {
        value = 1,
        min = 1,
        max = 1,        
    }

    local comm = {
        value = 1,
        min = 1,
        max = 1,        
    }

    local surv = {
        value = 1,
        min = 1,
        max = 1,        
    }

    return phys, subt, know, comm, surv
end

local function getStatValues(race)
    local str = {
        value = 0,
        min = 3 + (race == 'Dwarf' and 2 or 0),
        max = 18 + (race == 'Dwarf' and 2 or 0)
    }

    local dex = {
        value = 0,
        min = 3 + (race == 'Halfling' and 2 or 0),
        max = 18 + (race == 'Halfling' and 2 or 0),
    }

    local mind = {
        value = 0,
        min = 3 + (race == 'Elf' and 2 or 0),
        max = 18 + (race == 'Elf' and 2 or 0),
    }

    for _, stat in ipairs({ str, dex, mind }) do
        -- roll 1d6, store 4 values
        local values = {}
        for i = 1, 4 do
            table.insert(values, ndn.dice('1d6').roll())
        end
        
        -- sort values descending
        table.sort(values, function(a, b) return a > b end)

        -- use the 3 highest values as stat value
        local value = 0
        for j = 1, 3 do stat.value = stat.value + values[j] end        
    end

    return str, dex, mind
end

NewPlayer.new = function()
    local image = TextureGenerator.generatePanelTexture(120, 48)

    local lines = {}

    local buttons = {}

    local gender, race, class, stats, skills = nil, nil, nil, nil, nil
    
    local function onSelectGender()
        Gamestate.push(ChooseOption(
            'CHOOSE GENDER', 
            function(gender_) 
                gender = gender_ 
            end,
            'Male', 'Female'))
    end

    local function onSelectRace()        
        Gamestate.push(ChooseOption(
            'CHOOSE RACE', 
            function(race_) 
                race = race_
                class = nil 
            end,
            'Human', 'Elf', 'Dwarf', 'Halfling'))
    end

    local function onSelectClass()
        Gamestate.push(ChooseOption(
            'CHOOSE CLASS', 
            function(class_) 
                class = class_ 
            end,
            'Fighter', 'Mage', 'Cleric', 'Rogue'))
    end

    local function onSelectStats()
        local str, dex, mind = getStatValues(race)
        
        Gamestate.push(AssignPoints(
            'ASSIGN STATS',
            {
                { key = 'Strength',  value = str.value,  min = str.min,  max = str.max  },                
                { key = 'Dexterity', value = dex.value,  min = dex.min,  max = dex.max  },
                { key = 'Mind',      value = mind.value, min = mind.min, max = mind.max },
            }, 
            0))
    end

    local function onSelectSkills()
        local phys, subt, know, comm, surv = getSkillValues(race)

        Gamestate.push(AssignPoints(
            'ASSIGN SKILLS', 
            {
                { key = 'Physical',         value = phys.value, min = phys.min, max = phys.max },
                { key = 'Subterfuge',       value = subt.value, min = subt.min, max = subt.max },
                { key = 'Knowledge',        value = know.value, min = know.min, max = know.max },
                { key = 'Communication',    value = comm.value, min = comm.min, max = comm.max },
                { key = 'Survival',         value = surv.value, min = surv.min, max = surv.max },
            }, 
            0))
    end

    local function onChangeName()
        print('change name')
    end

    local function onChangePortrait()
        print('change portrait')
    end

    buttons = {
        UI.makeButton(onSelectGender, generateButtonTexture('GENDER')),
        UI.makeButton(onSelectRace, generateButtonTexture('RACE')),
        UI.makeButton(onSelectClass, generateButtonTexture('CLASS')),
        UI.makeButton(onSelectStats, generateButtonTexture('STATS')),
        UI.makeButton(onSelectSkills, generateButtonTexture('SKILLS')),
        UI.makeButton(onChangeName, generateButtonTexture('NAME')),
        UI.makeButton(onChangePortrait, generateButtonTexture('PORTRAIT')),
    }
    for idx = 2, #buttons do buttons[idx].widget:setEnabled(false) end

    local layout = tidy.Border(tidy.Margin(180, 10, 180, 10), {
        tidy.HStack(tidy.Spacing(10), {
            tidy.VStack(tidy.MinSize(0, 120), tidy.Spacing(2), buttons),
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

    local resume = function(self, from)
        if gender then buttons[2].widget:setEnabled(true) end
        if race then buttons[3].widget:setEnabled(true) end
        buttons[4].widget:setEnabled(class ~= nil)
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
        resume      = resume,
        keyReleased = keyReleased,
    }, NewPlayer)
end

return setmetatable(NewPlayer, {
    __call = function(_, ...) return NewPlayer.new(...) end,
})
