--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

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
    local background = TextureGenerator.generateParchmentTexture(220, 340)

    local class = player:getComponent(Class)
    local skills = player:getComponent(Skills)
    local stats = player:getComponent(Stats)
    local health = player:getComponent(Health)

    local frame = getFrame(background)

    local game = nil

    local name = player.name:upper()
    if not health:isAlive() then name = name .. ' (deceased)' end

    local STR_PAD = 8

    local exp, exp_goal = class:getExp()
    local text = StringHelper.concat({ 
        name,
        StringHelper.capitalize(player.class) .. ' level ' .. class:getLevel(),
        'Experience:    ' .. StringHelper.padRight(exp .. ' / ' .. exp_goal, STR_PAD),
        '',
        'STATS',
        'strength:      ' .. StringHelper.padRight(getStatLine(stats, 'str'), STR_PAD),
        'dexterity:     ' .. StringHelper.padRight(getStatLine(stats, 'dex'), STR_PAD),
        'mind:          ' .. StringHelper.padRight(getStatLine(stats, 'mind'), STR_PAD),
        '',
        'SKILLS',
        'physical:      ' .. StringHelper.padRight(tostring(skills:getValue('phys')), STR_PAD),
        'subterfuge:    ' .. StringHelper.padRight(tostring(skills:getValue('subt')), STR_PAD),
        'knowledge:     ' .. StringHelper.padRight(tostring(skills:getValue('know')), STR_PAD),
        'communication: ' .. StringHelper.padRight(tostring(skills:getValue('comm')), STR_PAD),
        '',
        'SAVES',
        'fortitude:     ' .. StringHelper.padRight(tostring(skills:getValue('phys') + stats:getBonus('str')), STR_PAD),
        'reflex:        ' .. StringHelper.padRight(tostring(skills:getValue('phys') + stats:getBonus('dex')), STR_PAD),
        'will:          ' .. StringHelper.padRight(tostring(stats:getBonus('mind') + class:getLevel()), STR_PAD),
    }, '\n')

    local update = function(self, dt) 
        -- body
    end

    local draw = function(self)
        game:draw()

        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)

        love.graphics.print(text, x + 10, y + 15)
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
