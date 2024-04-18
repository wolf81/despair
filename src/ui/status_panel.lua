--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local StatusPanel = {}

StatusPanel.new = function(player)
    -- local health_bar = ResourceBar(player, 'health')
    -- local energy_bar = ResourceBar(player, 'energy')

    -- local bar_w, bar_h = health_bar:getSize()

    local cartographer = player:getComponent(Cartographer)

    local frame = Rect(0)

    local layout = tidy.Border(tidy.Margin(14), {
        tidy.VStack(tidy.Spacing(10), {
            tidy.HStack(tidy.Spacing(6), {
                UI.makeLabel('HEALTH'),
                UI.makeLabel('HUNGER'),
            }),
            tidy.HStack(tidy.Spacing(6), {
                UI.makeResourceBar(player, 'health'),
                UI.makeResourceBar(player, 'energy'),
            }),
            tidy.HStack({
                UI.makeFlexSpace(),
                UI.makeChart(cartographer),
                UI.makeFlexSpace(),                
            }),
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
    }, StatusPanel)
end

return setmetatable(StatusPanel, {
    __call = function(_, ...) return StatusPanel.new(...) end,
})
