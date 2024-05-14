--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, lrandom = math.floor, love.math.random

local NewPlayer = {}

local GENDERS   = { 'Male', 'Female' }
local RACES     = { 'Human', 'Elf', 'Dwarf', 'Halfling' }
local CLASSES   = { 'Fighter' , 'Mage', 'Cleric', 'Rogue' }

local CLASS_ANIM = {
    ['fighter'] = { 21, 22, 23, 24 },
    ['cleric']  = { 17, 18, 19, 20 },
    ['rogue']   = { 29, 30, 31, 32 },
    ['mage']    = {  1,  2,  3,  4 },
}

local CLASS_EQUIP = {
    ['fighter'] = { 'chain_mail', 'light_shield', 'longsword', 'food_1', 'food_1' },
    ['cleric']  = { 'chain_mail', 'morningstar', 'food_1', 'food_1' },
    ['rogue']   = { 'stud_leather', 'short_sword', 'short_sword', 'food_1', 'food_1' },
    ['mage']    = { 'robe', 'quarterstaff', 'food_1', 'food_1' },    
}

local RACE_FLAGS = {
    ['halfling']    = {},
    ['dwarf']       = { 'DV' }, -- TODO: implement darkvision
    ['human']       = {},
    ['elf']         = {},
}

local RACE_SPEED = {
    ['halfling']    = 30,
    ['dwarf']       = 25,
    ['human']       = 30,
    ['elf']         = 30,
}

local function padRight(value, len)
    return StringHelper.padRight(tostring(value), len)
end

local function padLeft(value, len)
    return StringHelper.padLeft(tostring(value), len)
end

local function getStatLine(value, len)
    local s = tostring(value)
    local bonus = mfloor((value - 10) / 2)
    if bonus < 0 then 
        s = s .. ' (' .. bonus .. ')'
    else
        s = s .. ' (+' .. bonus .. ')'
    end
    return padRight(s, len)
end

local function loadLevels()
    local levels_dir = 'gen/levels'
    local dir_path = love.filesystem.getRealDirectory(levels_dir)
    local files = love.filesystem.getDirectoryItems(levels_dir)
    local level_data = {}
    for _, file in ipairs(files) do
        local filepath = dir_path .. '/' .. levels_dir .. '/' .. file
        local getContents = assert(loadfile(filepath))
        table.insert(level_data, getContents())
    end

    -- sort by level index
    table.sort(level_data, function(a, b) return a.level < b.level end)

    return level_data
end

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(120, 32, title)
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

    local parchment = UI.makeParchment('', 20)
    local portrait = UI.makePortrait(nil, nil, nil)
    portrait.widget:setRotation(0.1)

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
                portrait.widget:setIdentifier(nil)
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
                portrait.widget:setIdentifier(nil)
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
                portrait.widget:setIdentifier(nil)
            end,
            unpack(CLASSES)))
    end

    local function onSelectStats()
        local str, dex, mind = getStatValues(race)
        
        Gamestate.push(AssignPoints(
            'ASSIGN STATS',
            function(str_, dex_, mind_) 
                stats = { 
                    str = { value = str_ }, 
                    dex = { value = dex_ }, 
                    mind = { value = mind_ },
                }
                skills = nil
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
                skills = { 
                    phys = { value = phys_ }, 
                    subt = { value = subt_ }, 
                    know = { value = know_ }, 
                    comm = { value = comm_ }, 
                    surv = { value = surv_ },
                }
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
        local enter_name = EnterName(function(name_) 
            name = name_ 
            portrait.widget:setIdentifier(nil)
        end)
        enter_name:setName(name)

        Gamestate.push(enter_name)
    end

    local function onChangePortrait()
        print('change portrait')

        local make_portrait = MakePortrait(gender or 'Male', race or 'Human', class or 'Fighter', function(portrait_id)
            portrait.widget:setIdentifier(portrait_id)
        end)
        make_portrait:setIdentifier(portrait.widget:getIdentifier())

        Gamestate.push(make_portrait)
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

        local portrait_id = Portrait(gender, race, class):getIdentifier()
        portrait.widget:configure(gender, race, class)
        portrait.widget:setIdentifier(portrait_id)

        needs_update = true
    end

    local function onBack()
        Gamestate.switch(MainMenu())
    end

    local function onPlay()
        local class_name = string.lower(class)
        local race_name = string.lower(race)
        local gender_name = string.lower(gender)
        local player_id = 'pc'
        local portrait_id = portrait.widget:getIdentifier()

        EntityFactory.register({
            id = player_id,
            type = 'pc',
            name = name,
            gender = gender_name,
            race = race_name,
            class = class_name,
            level = 1,
            sight = 60,
            speed = RACE_SPEED[race_name],
            str = stats.str.value,
            dex = stats.dex.value,
            mind = stats.mind.value,
            flags = RACE_FLAGS[race_name],
            equip = CLASS_EQUIP[class_name],
            texture = 'uf_heroes',
            anim = CLASS_ANIM[class_name],
            portrait_id = portrait_id,
        })

        local level_info = loadLevels()
        Gamestate.switch(Loading(Game, 'game', level_info, player_id))
    end
    
    local char_buttons = {
        UI.makeButton(onSelectGender, generateTextButtonTexture('GENDER')),
        UI.makeButton(onSelectRace, generateTextButtonTexture('RACE')),
        UI.makeButton(onSelectClass, generateTextButtonTexture('CLASS')),
        UI.makeButton(onSelectStats, generateTextButtonTexture('STATS')),
        UI.makeButton(onSelectSkills, generateTextButtonTexture('SKILLS')),
        UI.makeButton(onChangeName, generateTextButtonTexture('NAME')),
        UI.makeButton(onChangePortrait, generateTextButtonTexture('PORTRAIT')),
        UI.makeFlexSpace(),
        UI.makeButton(onChooseRandom, generateTextButtonTexture('RANDOM')),
        UI.makeFlexSpace(),
    }
    local back_button = UI.makeButton(onBack, generateTextButtonTexture('BACK'))
    local play_button = UI.makeButton(onPlay, generateTextButtonTexture('PLAY'))

    local layout = tidy.Border(tidy.Margin(200, 10, 200, 10), {
        tidy.VStack(tidy.Spacing(10), {
            tidy.HStack(tidy.Spacing(10), tidy.Stretch(1), {
                tidy.VStack(tidy.MinSize(0, 120), tidy.Spacing(2), char_buttons),
                parchment,
            }),
            tidy.HStack({
                back_button,
                UI.makeFlexSpace(),
                play_button,
            }),
        }),
    }):setFrame(0, 0, WINDOW_W, WINDOW_H)

    local draw = function(self)
        love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
        love.graphics.rectangle('fill', 0, 0, WINDOW_W, WINDOW_H)

        for e in layout:eachElement() do e.widget:draw() end

        portrait.widget:setFrame(WINDOW_W - 200 - 60, 20, 48, 48)
        portrait.widget:draw()
    end

    local update = function(self, dt)
        if needs_update then
            char_buttons[2].widget:setEnabled(gender ~= nil)
            char_buttons[3].widget:setEnabled(race ~= nil)
            char_buttons[4].widget:setEnabled(class ~= nil)
            char_buttons[5].widget:setEnabled(stats ~= nil)
            char_buttons[6].widget:setEnabled(name ~= nil or skills ~= nil)
            char_buttons[7].widget:setEnabled(name ~= nil)
            portrait.widget:configure(gender, race, class)
            play_button.widget:setEnabled(portrait.widget:getIdentifier() ~= nil)

            local lines = {}
            if name then 
                table.insert(lines, name) 
            else
                table.insert(lines, 'Anonymous')
            end
            
            if gender then table.insert(lines, gender) end
            
            if race then
                if class then table.insert(lines, race .. ' ' .. class) 
                else table.insert(lines, race) end
            end

            if stats then
                table.insert(lines, '\n')
                table.insert(lines, 'STATS')
                table.insert(lines, padLeft('Strength:', 16)      .. getStatLine(stats.str.value, 12))
                table.insert(lines, padLeft('Dexterity:', 16)     .. getStatLine(stats.dex.value, 12))
                table.insert(lines, padLeft('Mind:', 16)          .. getStatLine(stats.mind.value, 12))
            end

            if skills then
                table.insert(lines, '\n')
                table.insert(lines, 'SKILLS')
                table.insert(lines, padLeft('Physical:', 16)      .. padRight(skills.phys.value, 12))
                table.insert(lines, padLeft('Subterfuge:', 16)    .. padRight(skills.subt.value, 12))
                table.insert(lines, padLeft('Communication:', 16) .. padRight(skills.comm.value, 12))
                table.insert(lines, padLeft('Knowledge:', 16)     .. padRight(skills.know.value, 12))
                table.insert(lines, padLeft('Survival:', 16)      .. padRight(skills.surv.value, 12))
            end

            parchment.widget:setText(table.concat(lines, '\n'))

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

    -- configure initial state
    for idx = 2, 6 do char_buttons[idx].widget:setEnabled(false) end
    play_button.widget:setEnabled(false)

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
