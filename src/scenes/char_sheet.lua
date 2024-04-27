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
    local background = TextureGenerator.generateParchmentTexture(220, 310)

    local exp_level = player:getComponent(ExpLevel)
    local skills = player:getComponent(Skills)
    local stats = player:getComponent(Stats)
    local health = player:getComponent(Health)

    local frame = getFrame(background)

    local game = nil

    local name = player.name:upper()
    if not health:isAlive() then name = name .. ' (deceased)' end

    -- TODO: make a single string, not seperate lines
    local exp, exp_goal = exp_level:getExp()
    local lines = { 
        name,
        StringHelper.capitalize(player.class) .. ' level ' .. exp_level:getLevel(),
        'Experience:    ' .. exp .. ' / ' .. exp_goal,
        '',
        'STATS',
        'strength:      ' .. getStatLine(stats, 'str'),
        'dexterity:     ' .. getStatLine(stats, 'dex'),
        'mind:          ' .. getStatLine(stats, 'mind'),
        '',
        'SKILLS',
        'physical:      ' .. skills:getValue('phys'),
        'subterfuge:    ' .. skills:getValue('subt'),
        'knowledge:     ' .. skills:getValue('know'),
        'communication: ' .. skills:getValue('comm'),
        '',
        'SAVES',
        'fortitude:     ' .. skills:getValue('phys') + stats:getBonus('str'),
        'reflex:        ' .. skills:getValue('phys') + stats:getBonus('dex'),
        'will:          ' .. stats:getBonus('mind') + exp_level:getLevel(),
    }

    local update = function(self, dt) 
        -- body
    end

    local draw = function(self)
        game:draw()

        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)

        for idx, line in ipairs(lines) do
            love.graphics.print(line, x + 10, y + idx * 15)
        end
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
