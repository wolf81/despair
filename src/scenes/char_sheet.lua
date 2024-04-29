--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local padRight, capitalize = StringHelper.padRight, StringHelper.capitalize

local CharSheet = {}

local function getStatLine(stats, stat)
    local value = stats:getValue(stat)
    local bonus = stats:getBonus(stat)
    return value .. ' (' .. (bonus < 0 and ('-' .. bonus) or ('+' .. bonus)) .. ')'
end

local function getFrame(background)
    local w, h = background:getDimensions()
    local x = (WINDOW_W - w) / 2
    local y = (WINDOW_H - h) / 2
    return Rect(x, y, w, h)
end

CharSheet.new = function(player)
    local background = TextureGenerator.generateParchmentTexture(460, 300)

    local race = player:getComponent(Race)
    local class = player:getComponent(Class)
    local stats = player:getComponent(Stats)
    local skills = player:getComponent(Skills)
    local health = player:getComponent(Health)
    local offense = player:getComponent(Offense)

    local frame = getFrame(background)

    local game = nil

    local name = player.name:upper()
    if not health:isAlive() then name = name .. ' (deceased)' end

    local STR_PAD = 8

    local hp, hp_total = health:getValue()

    local exp, exp_goal = class:getExp()
    local left_text = StringHelper.concat({ 
        name,
        StringHelper.capitalize(race:getRaceName()) .. ' ' .. StringHelper.capitalize(class:getClassName()) .. ' level ' .. class:getLevel(),
        '',
        'Experience:    ' .. padRight(exp .. ' / ' .. exp_goal, STR_PAD),
        'Hitpoints:     ' .. padRight(hp .. ' / ' .. hp_total, STR_PAD),
        '',
        'STATS',
        'strength:      ' .. padRight(getStatLine(stats, 'str'), STR_PAD),
        'dexterity:     ' .. padRight(getStatLine(stats, 'dex'), STR_PAD),
        'mind:          ' .. padRight(getStatLine(stats, 'mind'), STR_PAD),
        '',
        'SKILLS',
        'physical:      ' .. padRight(tostring(skills:getValue('phys')), STR_PAD),
        'subterfuge:    ' .. padRight(tostring(skills:getValue('subt')), STR_PAD),
        'knowledge:     ' .. padRight(tostring(skills:getValue('know')), STR_PAD),
        'communication: ' .. padRight(tostring(skills:getValue('comm')), STR_PAD),
    }, '\n')

    local right_text = StringHelper.concat({
        'SAVES',
        'fortitude:     ' .. padRight(tostring(skills:getValue('phys') + stats:getBonus('str')), STR_PAD),
        'reflex:        ' .. padRight(tostring(skills:getValue('phys') + stats:getBonus('dex')), STR_PAD),
        'will:          ' .. padRight(tostring(stats:getBonus('mind') + class:getLevel()), STR_PAD),
        '',
        'COMBAT',
        'Attack:        ' .. padRight(tostring(''), STR_PAD),
        'Damage:        ' .. padRight(tostring(''), STR_PAD),
    }, '\n')

    local textColor = { 0.0, 0.0, 0.0, 0.7 }
    local background_w, background_h = background:getDimensions()

    -- configure layout
    local layout = tidy.Border(tidy.Margin(20), {
        tidy.HStack({
            tidy.VStack(tidy.Stretch(1), {
                UI.makeLabel(left_text, textColor),
            }),
            UI.makeFixedSpace(40, 0),
            tidy.VStack(tidy.Stretch(1), {
                UI.makeLabel(right_text, textColor),
            })
        })
    })
    local x = mfloor((WINDOW_W - background_w) / 2)
    local y = mfloor((WINDOW_H - background_h) / 2)
    layout:setFrame(x, y, background_w, background_h)
    for e in layout:eachElement() do
        e.widget:setFrame(e.rect:unpack())
    end
    --]]

    local update = function(self, dt) 
        -- body
    end

    local draw = function(self)
        game:draw()

        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.line(x + background_w / 2, y, x + background_w / 2, y + background_h)

        for e in layout:eachElement() do
            e.widget:draw()
        end

        -- love.graphics.print(text, x + 10, y + 15)
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
        draw            = draw,
        enter           = enter,
        leave           = leave,
        update          = update,
        keyReleased     = keyReleased,
        mouseReleased   = mouseReleased,
    }, CharSheet)
end

return setmetatable(CharSheet, {
    __call = function(_, ...) return CharSheet.new(...) end,
})
