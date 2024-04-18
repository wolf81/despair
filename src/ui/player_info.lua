--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local PlayerInfo = {}

PlayerInfo.new = function(player)
    -- local health_bar = ResourceBar(player, 'health')
    -- local energy_bar = ResourceBar(player, 'energy')

    -- local bar_w, bar_h = health_bar:getSize()

    local cartographer = player:getComponent(Cartographer)

    local frame = Rect(0)

    local layout = tidy.Border(tidy.Margin(14), {
        tidy.VStack(tidy.Spacing(10), {
            tidy.HStack({
                UI.makeLabel('HEALTH'),
                UI.makeLabel('HUNGER'),
            }), -- TODO: why isn't size properly calculated for this stack?
            tidy.HStack({
                UI.makeResourceBar(player, 'health'),
                UI.makeResourceBar(player, 'energy'),
            }),
            UI.makeChart(cartographer),
        }),
    })

    local background = nil

    local update = function(self, dt)
        -- health_bar:update(dt)
        -- energy_bar:update(dt)
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


        -- love.graphics.setFont(FONT)

        -- local x, y, w, h = frame:unpack()

        -- love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        -- love.graphics.draw(background, x, y)

        -- local bar_x = x + 15
        -- local bar_y = 20
        -- love.graphics.print("HEALTH", bar_x, bar_y)
        -- health_bar:draw(bar_x, bar_y + 10)
        -- love.graphics.print("HUNGER", bar_x + 60, bar_y)
        -- energy_bar:draw(bar_x + 60, bar_y + 10)

        -- local chart = cartographer:getChart()
        -- local chart_w, _ = chart:getSize()
        -- local chart_x = mfloor((w - chart_w) / 2)

        -- chart:draw(x + chart_x, 50)
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
        setFrame    = setFrame,
        update      = update,
        draw        = draw,
    }, PlayerInfo)
end

return setmetatable(PlayerInfo, {
    __call = function(_, ...) return PlayerInfo.new(...) end,
})
