--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

io.stdout:setvbuf('no')

require 'dependencies'
require 'constants'

local function trySetCursor()
    if not love.mouse.isCursorSupported() then return end

    local cursor = love.mouse.newCursor('gfx/pointer.png', 1, 1)
    love.mouse.setCursor(cursor)
end

local function configureGraphics()
    FONT:setLineHeight(2.0)
    love.graphics.setFont(FONT)

    love.graphics.setLineStyle('rough')
end

function love.load(args)
    love.window.setTitle('Dungeon of Despair')

    success = love.window.setMode(WINDOW_W * UI_SCALE, WINDOW_H * UI_SCALE, {
        highdpi = false,
    })

    -- handle command line args, if any
    -- PLEASE NOTE: for Windows might need to add `--console` as well
    for _, arg in ipairs(args) do
        if arg == '--quadsheet' then
            return Gamestate.switch(Loading(MainMenu, 'all', function() 
                QuadSheetGenerator.generate()
                love.event.quit()
            end))
        elseif arg == '--imagefont' then
            FontSheetGenerator.generate()
            love.event.quit()
        end
    end

    configureGraphics()

    trySetCursor()

    GamestateHelper.fixGamestatePushPop()

    Gamestate.switch(Loading(MainMenu, 'ui'))
end

function love.update(dt)
    Timer.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(UI_SCALE)
    Gamestate.draw()
    love.graphics.pop()
end

function love.textinput(t)
    Gamestate.textInput(t)
end

function love.keypressed(key, scancode, isrepeat)
    Gamestate.keyPressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    Gamestate.keyReleased(key, scancode)
end

function love.mousemoved(x, y, dx, dy, istouch)
    Gamestate.mouseMoved(x, y, dx, dy, istouch)
end

function love.mousereleased(x, y, button, istouch, presses)
    Gamestate.mouseReleased(x, y, button, istouch, presses)
end

function love.mousepressed(x, y, button, istouch, presses)
    Gamestate.mousePressed(x, y, button, istouch, presses)
end
