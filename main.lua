--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

io.stdout:setvbuf('no')

require 'dependencies'
require 'constants'

function love.load(args)
    love.window.setTitle('Dungeon of Despair')

    -- init graphics for pointer device
    Pointer.init()

    success = love.window.setMode(WINDOW_W * SCALE, WINDOW_H * SCALE, {
        highdpi = false,
    })

    -- handle command line args, if any
    -- PLEASE NOTE: for Windows might need to add `--console` as well
    for _, arg in ipairs(args) do
        if arg == '--quadsheet' then
            QuadSheetGenerator.generate()
            love.event.quit()
        elseif arg == '--imagefont' then
            FontSheetGenerator.generate()            
            love.event.quit()
        end
    end

    love.graphics.scale(SCALE)

    FONT:setLineHeight(15)

    Gamestate.registerEvents()
    Gamestate.switch(Loading())
end

function love.update(dt)
    Timer.update(dt)
    -- game:update(dt)
end

function love.draw()

    -- game:draw()
end
