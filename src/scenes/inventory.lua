--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local Inventory = {}

local TEXT_COLOR = { 0.0, 0.0, 0.0, 0.7 }

local EQUIP_SLOT_INFO = TableHelper.readOnly({
    [1]     = 'head',
    [2]     = 'mainhand',
    [3]     = 'neck',
    [4]     = 'offhand',
    [5]     = 'back',
    [6]     = 'chest',
    [7]     = 'hands',
    [8]     = 'ring1',
    [9]     = 'legs',
    [10]    = 'ring2',
    [11]    = 'feet',
})

local function getWeapons(equipment)
    local weapons = {}

    local eq_mainhand = equipment:getItem('mainhand')
    if eq_mainhand ~= nil and eq_mainhand.type == 'weapon' then
        table.insert(weapons, eq_mainhand)
    end

    local eq_offhand = equipment:getItem('offhand')
    if eq_offhand ~= nil and eq_offhand.type == 'weapon' then
        table.insert(weapons, eq_offhand)
    end

    return weapons
end

local function updateCombatInfo(combat_info, equipment, offense, defense)
    local weapons = getWeapons(equipment)    
    local is_dual_wielding = #weapons == 2

    local att_value = 'ATTACK BONUS: '
    local dmg_value = 'DAMAGE:       '

    for idx, weapon in ipairs(weapons) do
        local dmg_min, dmg_max = ndn.dice(weapon.damage):range()
        local bonus = offense:getDamageBonus(weapon)

        att_value = att_value .. offense:getAttackValue(weapon, is_dual_wielding)
        dmg_value = dmg_value .. (dmg_min + bonus) .. '-' .. (dmg_max + bonus)

        if idx < #weapons then
            att_value = att_value .. '/' 
            dmg_value = dmg_value .. '/'
        end
    end
    
    local ac_value  = 'ARMOR CLASS:  ' .. defense:getArmorValue()

    combat_info.widget:setText('COMBAT STATS\n' .. 
        att_value .. '\n' .. 
        dmg_value .. '\n' .. 
        ac_value)
end

local function updateHoverInfo(hover_info, item)
    local text = ''
    
    if item then
        local info = item:getComponent(Info)
        text = info:getName() .. '\n' .. info:getDescription()
    end

    hover_info.widget:setText(text)
end

local function updateItemContainers(item_containers, equipment, backpack)
    for idx = 1, 11 do
        local slot = EQUIP_SLOT_INFO[idx]
        item_containers[idx].widget:setItem(equipment:getItem(slot))
    end

    for idx = 1, select(2, backpack:getSize()) do
        item_containers[idx + 11].widget:setItem(backpack:peek(idx))
    end
end

-- TODO: need title bar and close button
Inventory.new = function(player)
    -- components for drawing items
    local equipment = player:getComponent(Equipment)
    local backpack = player:getComponent(Backpack)

    -- components for drawing combat stats
    local offense = player:getComponent(Offense)
    local defense = player:getComponent(Defense)

    -- the background image
    local background = TextureGenerator.generatePanelTexture(480, 380)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - STATUS_PANEL_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - ACTION_BAR_H - background_h) / 2)
    local frame = Rect(background_x, background_y, background_w, background_h)

    -- item slots for equipment & backpack
    local item_containers = {}
    for i = 1, 41 do
        -- equipment: 1..11
        -- backpack: 12..41
        table.insert(item_containers, UI.makeItemContainer())
    end

    -- combat & item info displayed at the bottom of the screen
    local combat_info = UI.makeParchment()
    local hover_info = UI.makeParchment()

    -- configure layout
    local layout = tidy.Border(tidy.Margin(15), {
        tidy.VStack(tidy.Spacing(10), {
            tidy.HStack(tidy.Spacing(10), {
                tidy.VStack(tidy.Spacing(10), {
                    UI.makeLabel('EQUIPMENT'),
                    tidy.VStack(tidy.Spacing(1), {
                        tidy.HStack(tidy.Spacing(1), {
                            UI.makeFlexSpace(),
                            item_containers[1],
                            UI.makeFlexSpace(),
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[2],
                            item_containers[3],
                            item_containers[4],
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[5],
                            item_containers[6],
                            item_containers[7],
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[8],
                            item_containers[9],
                            item_containers[10],
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            UI.makeFlexSpace(),
                            item_containers[11],
                            UI.makeFlexSpace(),
                        }),
                    }),
                }),
                tidy.VStack(tidy.Spacing(10), {
                    UI.makeLabel('BACKPACK'),
                    tidy.VStack(tidy.Spacing(1), {
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[12],
                            item_containers[13],
                            item_containers[14],
                            item_containers[15],
                            item_containers[16],
                            item_containers[17],
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[18],
                            item_containers[19],
                            item_containers[20],
                            item_containers[21],
                            item_containers[22],
                            item_containers[23],
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[24],
                            item_containers[25],
                            item_containers[26],
                            item_containers[27],
                            item_containers[28],
                            item_containers[29],
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[30],
                            item_containers[31],
                            item_containers[32],
                            item_containers[33],
                            item_containers[34],
                            item_containers[35],
                        }),
                        tidy.HStack(tidy.Spacing(1), {
                            item_containers[36],
                            item_containers[37],
                            item_containers[38],
                            item_containers[39],
                            item_containers[40],
                            item_containers[41],
                        }),
                    }),                
                }),
            }),
            tidy.HStack(tidy.Spacing(10), {
                combat_info,
                hover_info,
            }),
        }),
    }):setFrame(background_x, background_y, background_w, background_h)

    local overlay = Overlay()

    updateItemContainers(item_containers, equipment, backpack)
    updateCombatInfo(combat_info, equipment, offense, defense)        

    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()

        mx, my = mx / UI_SCALE, my / UI_SCALE

        for idx, item_container in ipairs(item_containers) do
            local x, y, w, h = item_container.widget:getFrame()
            if mx > x and mx < x + w and my > y and my < y + h then
                updateHoverInfo(hover_info, item_container.widget:getItem())
            end
        end

        for e in layout:eachElement() do e.widget:update(dt) end
    end

    local game = nil

    local enter = function(self, from)
        assert(getmetatable(from) == Game, 'invalid argument for "from", expected: "Game"')
        
        game = from
        overlay:fadeIn()

        -- TODO: maybe we don't need this 'hacky' way to change mouse visibility if we control 
        -- visiblity from Game class, instead of Pointer class
        love.mouse.setVisible(true)
    end

    local leave = function(self, to) game = nil end

    local draw = function(self)
        -- draw game behind inventory        
        game:draw()

        overlay:draw()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, background_x, background_y)

        for e in layout:eachElement() do e.widget:draw(dt) end
    end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            overlay:fadeOut(Gamestate.pop)
        end
    end

    local mouseReleased = function(self, mx, my, mouse_btn)
        if not frame:contains(mx, my) then return overlay:fadeOut(Gamestate.pop) end

        if mouse_btn ~= 2 then return end
        
        for idx, item_container in ipairs(item_containers) do
            local x, y, w, h = item_container.widget:getFrame()
            if mx > x and mx < x + w and my > y and my < y + h then
                if idx > 11 then
                    local item_idx = idx - 11
                    local item = backpack:peek(item_idx)
                    if item then 
                        local equippable = item:getComponent(Equippable)        
                        if equippable then
                            if equippable:equip(player) then
                                backpack:take(item_idx)
                            end
                        end
                    end
                else
                    if backpack:isFull() then
                        return Signal.emit(
                            'notify', 'Cannot place item in backpack, backpack is already full.')
                    end

                    equipment:unequip(EQUIP_SLOT_INFO[idx])
                end

                updateItemContainers(item_containers, equipment, backpack)

                return
            end
        end

        -- update game to show current health and energy after eating food, drinking potion, ...
        game:update(0)
    end

    return setmetatable({
        -- methods
        draw            = draw,
        enter           = enter,
        leave           = leave,
        update          = update,
        keyReleased     = keyReleased,
        mouseReleased   = mouseReleased,
    }, Inventory)
end

return setmetatable(Inventory, {
    __call = function(_, ...) return Inventory.new(...) end,
})
