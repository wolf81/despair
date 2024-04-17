--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

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
    return { x, y, w, h }
end

CharSheet.new = function(player)
    local background = TextureGenerator.generateParchmentTexture(220, 310)

    local exp_level = player:getComponent(ExpLevel)
    local skills = player:getComponent(Skills)
    local stats = player:getComponent(Stats)

    local frame = getFrame(background)

    local game = nil

    local update = function(self, dt) 
        -- body
    end

    local draw = function(self)
        game:draw()

        local x, y = unpack(frame)

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)

        local lines = { 
            player.name:upper(),
            StringHelper.capitalize(player.class) .. ' level ' .. exp_level:getValue(),
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
            'will:          ' .. stats:getBonus('mind') + exp_level:getValue(),
        }

        for idx, line in ipairs(lines) do
            love.graphics.print(line, x + 10, y + idx * 15)
        end
    end

    local enter = function(self, from)
        game = from
        game:showOverlay()
    end

    local leave = function(self, to)
        game:hideOverlay()
        game = nil
    end

    local keyReleased = function(self, key, scancode)
        if key == "escape" then
            Gamestate.pop()
        end
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        local x, y, w, h = unpack(frame)
        if (mx < x) or (mx > x + w) or (my < y) or (my > y + h) then
            Gamestate.pop()
        end
    end

    return setmetatable({
        -- methods
        mouseReleased   = mouseReleased,
        keyReleased     = keyReleased,
        update          = update,
        enter           = enter,
        leave           = leave,
        draw            = draw,
    }, CharSheet)
end

return setmetatable(CharSheet, {
    __call = function(_, ...) return CharSheet.new(...) end,
})
