local MainMenu = {}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(120, 48, title)
end

local function onSettings()
    print('settings') 
end

local function onNewGame()
    Gamestate.switch(NewPlayer())
end

local function onContinue()
    print('continue') 
end

MainMenu.new = function()
    local frame = Rect(0)

    local layout = tidy.HStack({
        UI.makeFlexSpace(),
        tidy.VStack(tidy.Spacing(10), {
            UI.makeFlexSpace(),
            UI.makeButton(onNewGame, generateTextButtonTexture('NEW GAME')),
            UI.makeButton(onContinue, generateTextButtonTexture('CONTINUE')),
            UI.makeButton(onSettings, generateTextButtonTexture('SETTINGS')),
            UI.makeFlexSpace(),
        }),
        UI.makeFlexSpace(),
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

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame:unpack() end

    return setmetatable({
        -- methods
        draw        = draw,
        enter       = enter,
        leave       = leave,
        update      = update,
        setFrame    = setFrame,
        getFrame    = getFrame,        
    }, MainMenu)
end

return setmetatable(MainMenu, {
    __call = function(_, ...) return MainMenu.new(...) end,
})
