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

local getAttBonusText = function(weapons, offense)
    local s = ''

    for idx, weapon in ipairs(weapons) do
        s = s .. '+' .. offense:getAttackBonus(weapon, #weapons == 2)
        if idx < #weapons then
            s = s .. ' / '
        end
    end

    return s
end

local getDmgBonusText = function(weapons, offense)
    local s = ''

    for idx, weapon in ipairs(weapons) do
        s = s .. '+' .. offense:getDamageBonus(weapon, #weapons == 2)
        if idx < #weapons then
            s = s .. ' / '
        end
    end

    return s
end

CharSheet.new = function(player)
    local background = TextureGenerator.generateParchmentTexture(460, 304)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w - STATUS_PANEL_W) / 2)
    local background_y = mfloor((WINDOW_H - background_h - ACTION_BAR_H) / 2)
    local frame = Rect(background_x, background_y, background_w, background_h)

    local race = player:getComponent(Race)
    local class = player:getComponent(Class)
    local stats = player:getComponent(Stats)
    local skills = player:getComponent(Skills)
    local health = player:getComponent(Health)
    local equip = player:getComponent(Equipment)
    local offense = player:getComponent(Offense)
    local defense = player:getComponent(Defense)

    local game = nil

    local name = player.name:upper()
    if not health:isAlive() then name = name .. ' (deceased)' end

    local STR_PAD = 8

    local hp, hp_total = health:getValue()

    local overlay = Overlay()

    local exp, exp_goal = class:getExp()
    local left_text = table.concat({ 
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
        'survival:      ' .. padRight(tostring(skills:getValue('surv')), STR_PAD),
    }, '\n')

    local right_text = table.concat({
        'COMBAT',
        'Attack bonus:  ' .. padRight(getAttBonusText(equip:getWeapons(), offense), STR_PAD),
        'Damage bonus:  ' .. padRight(getDmgBonusText(equip:getWeapons(), offense), STR_PAD),
        'Armor bonus:   ' .. padRight('+' .. tostring(defense:getArmorBonus()), STR_PAD),
        '',
        'SAVES',
        'fortitude:     ' .. padRight(tostring(skills:getValue('phys') + stats:getBonus('str')), STR_PAD),
        'reflex:        ' .. padRight(tostring(skills:getValue('phys') + stats:getBonus('dex')), STR_PAD),
        'will:          ' .. padRight(tostring(stats:getBonus('mind') + class:getLevel()), STR_PAD),
    }, '\n')

    local textColor = { 0.0, 0.0, 0.0, 0.7 }

    -- configure layout
    local layout = tidy.HStack({
        tidy.Border(tidy.Margin(20), {
            tidy.VStack(tidy.Stretch(1), {
                UI.makeLabel(left_text, textColor),
            }),            
        }),
        UI.makeSeperator(),
        tidy.Border(tidy.Margin(20), {
            tidy.VStack(tidy.Stretch(1), {
                UI.makeLabel(right_text, textColor),
            })            
        }),
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
