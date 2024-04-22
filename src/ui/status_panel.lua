--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local StatusPanel = {}

StatusPanel.new = function(player)
    local cartographer = player:getComponent(Cartographer)

    local frame = Rect(0)

    local layout = tidy.Border(tidy.Margin(0, 20), {
        tidy.HStack({
            UI.makeFlexSpace(),
            tidy.VStack({
                tidy.HStack({
                    UI.makeLabel('HEALTH'),
                    UI.makeFlexSpace(), 
                    UI.makeLabel('HUNGER'),
                }),
                UI.makeFixedSpace(0, 10),
                tidy.HStack({
                    UI.makeResourceBar(player, 'health'),
                    UI.makeFlexSpace(),
                    UI.makeResourceBar(player, 'energy'),
                }),
                UI.makeFixedSpace(0, 10),
                tidy.HStack({
                    UI.makeFlexSpace(),
                    UI.makeChart(cartographer),
                    UI.makeFlexSpace(),                
                }),
            }),            
            UI.makeFlexSpace(),            
        })
    })

    local background = nil

    local update = function(self, dt)
        for e in layout:eachElement() do
            e.widget:update(dt)
        end        
    end

    local draw = function(self)
        -- TODO: add dummy background
        if not background then return end

        local x, y, w, h = frame:unpack()

        love.graphics.draw(background, x, y)

        for e in layout:eachElement() do
            e.widget:draw()
        end
    end

    local setFrame = function(self, x, y, w, h)
        frame = Rect(x, y, w, h)

        if w > 0 and h > 0 then
            background = TextureGenerator.generatePanelTexture(w, h)

            layout:setFrame(frame:unpack())
            for e in layout:eachElement() do
                e.widget:setFrame(e.rect:unpack())
            end
        end
    end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        setFrame    = setFrame,
    }, StatusPanel)
end

return setmetatable(StatusPanel, {
    __call = function(_, ...) return StatusPanel.new(...) end,
})
