--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, lrandom = math.floor, love.math.random

local NewPlayer = {}

local GENDERS   = { 'Male', 'Female' }
local RACES     = { 'Human', 'Elf', 'Dwarf', 'Halfling' }
local CLASSES   = { 'Fighter' , 'Mage', 'Cleric', 'Rogue' }

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(120, 48, title)
end

local function getSkillValues(race)
    local base = race == 'Human' and 2 or 1
    
    local phys = { value = base, min = base, max = base }
    local subt = { value = base, min = base, max = base }
    local know = { value = base, min = base, max = base }
    local comm = { value = base, min = base, max = base }
    local surv = { value = base, min = base, max = base }

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

local function getName(gender, race)
    local name = NameGenerator.generate(race, gender, function(type)
        local path = 'dat/names/' .. type .. '.lua' 
        local chunk, err = love.filesystem.load(path)
        local name_info = chunk()
        return name_info['names'] 
    end)

    return name
end

NewPlayer.new = function()
    local image = TextureGenerator.generatePanelTexture(120, 48)

    local lines = {}

    local buttons = {}

    local gender, race, class, stats, skills, name = nil, nil, nil, nil, nil, nil

    local needs_update = true
    
    local function onSelectGender()
        Gamestate.push(ChooseOption(
            'CHOOSE GENDER', 
            function(gender_) 
                gender = gender_ 
                race = nil
                class = nil 
                stats = nil
                skills = nil
                name = nil
            end,
            unpack(GENDERS)))
    end

    local function onSelectRace()        
        Gamestate.push(ChooseOption(
            'CHOOSE RACE', 
            function(race_) 
                race = race_
                class = nil 
                stats = nil
                skills = nil
                name = nil
            end,
            unpack(RACES)))
    end

    local function onSelectClass()
        Gamestate.push(ChooseOption(
            'CHOOSE CLASS', 
            function(class_) 
                class = class_ 
                stats = nil
                skills = nil
                name = nil
            end,
            unpack(CLASSES)))
    end

    local function onSelectStats()
        local str, dex, mind = getStatValues(race)
        
        Gamestate.push(AssignPoints(
            'ASSIGN STATS',
            function(str_, dex_, mind_) 
                stats = { str = str_, dex = dex_, mind = mind_ }
                skills = nil
                name = nil
            end,
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
            function(phys_, subt_, know_, comm_, surv_) 
                skills = { phys = phys_, subt = subt_, know = know_, comm = comm_, surv = surv_ }
                name = nil
            end,
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
        local enter_name = EnterName(function(name_) name = name_ end)
        enter_name:setName(name)

        Gamestate.push(enter_name)
    end

    local function onChangePortrait()
        print('change portrait')

        Gamestate.push(MakePortrait(gender or 'Male', race or 'Human', class or 'Fighter'))
    end

    local function onChooseRandom()
        print('choose random character')

        gender = GENDERS[lrandom(#GENDERS)]
        race = RACES[lrandom(#RACES)]
        class = CLASSES[lrandom(#CLASSES)]
        name = getName(gender, race)

        local str, dex, mind = getStatValues(race)
        stats = { str = str, dex = dex, mind = mind }

        local phys, subt, know, comm, surv = getSkillValues(race)
        skills = { phys = phys, subt = subt, know = know, comm = comm, surv = surv }

        needs_update = true
    end

    buttons = {
        UI.makeButton(onSelectGender, generateTextButtonTexture('GENDER')),
        UI.makeButton(onSelectRace, generateTextButtonTexture('RACE')),
        UI.makeButton(onSelectClass, generateTextButtonTexture('CLASS')),
        UI.makeButton(onSelectStats, generateTextButtonTexture('STATS')),
        UI.makeButton(onSelectSkills, generateTextButtonTexture('SKILLS')),
        UI.makeButton(onChangeName, generateTextButtonTexture('NAME')),
        UI.makeButton(onChangePortrait, generateTextButtonTexture('PORTRAIT')),
        UI.makeFlexSpace(),
        UI.makeButton(onChooseRandom, generateTextButtonTexture('RANDOM'))
    }
    for idx = 2, 6 do buttons[idx].widget:setEnabled(false) end

    local layout = tidy.Border(tidy.Margin(180, 10, 180, 10), {
        tidy.HStack(tidy.Spacing(10), {
            tidy.VStack(tidy.MinSize(0, 120), tidy.Spacing(2), buttons),
            UI.makeParchment('...', 20),
        }),
    }):setFrame(0, 0, WINDOW_W, WINDOW_H)

    local draw = function(self)
        love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
        love.graphics.rectangle('fill', 0, 0, WINDOW_W, WINDOW_H)

        for e in layout:eachElement() do e.widget:draw() end
    end

    local update = function(self, dt)
        if needs_update then
            buttons[2].widget:setEnabled(gender ~= nil)
            buttons[3].widget:setEnabled(race ~= nil)
            buttons[4].widget:setEnabled(class ~= nil)
            buttons[5].widget:setEnabled(stats ~= nil)
            buttons[6].widget:setEnabled(skills ~= nil)
            buttons[7].widget:setEnabled(name ~= nil)
            needs_update = false
        end

        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local enter = function(self, from)
        -- body
    end

    local leave = function(self, to)
        -- body
    end

    local resume = function(self, from) needs_update = true end

    local keyReleased = function(self, key, scancode)        
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
