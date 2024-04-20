--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

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

local function generateSlots(equipment, equip_x, equip_y, backpack, backpack_x, backpack_y)
    local slots = {}

    local spacing, size = 2, 48

    -- generate slots for equipment
    for i = 1, 11 do
        local x = (i == 1 or i == 11) and 2 or (1 + (i + 1) % 3)
        local y = (i == 11) and 5 or (i > 1) and mfloor((1 + i) / 3 + 1) or 1

        -- convert to pixel coords
        x = (x - 1) * (spacing + size)
        y = (y - 1) * (spacing + size)

        table.insert(slots, { 
            x   = equip_x + x,
            y   = equip_y + y,
            key = EQUIP_SLOT_INFO[#slots + 1],
        })
    end

    -- generate slots for backpack
    local _, max_size = backpack:getSize()
    for i = 1, max_size do
        -- convert index to pixel coords
        local y = mfloor((i - 1) / 6) * (size + spacing)
        local x = ((i  - 1) % 6) * (size + spacing)

        table.insert(slots, { 
            x   = backpack_x + x, 
            y   = backpack_y + y, 
            key = i, 
        })
    end

    return slots    
end

local function drawItem(item, x, y)
    if not item then return end

    local def = EntityFactory.getDefinition(item.id)
    local texture = TextureCache:get(def.texture)
    local quads = QuadCache:get(def.texture)
    local frame = def.anim[1]

    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.draw(texture, quads[frame], x, y)
end

local newBackground = function(width, height)
    local texture = TextureGenerator.generatePanelTexture(width, height)
    local w, h = texture:getDimensions()
    local x = mfloor((WINDOW_W - w) / 2)
    local y = mfloor((WINDOW_H - h) / 2)

    local draw = function()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, x, y)
    end

    local getFrame = function() return Rect(x, y, w, h) end

    return TableHelper.readOnly({
        x = x,
        y = y,
        w = w,
        h = h,
        draw = draw,
        getFrame = getFrame,
    })
end

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

local function drawCombatStats(equipment, offense, defense, x, y, w, h)
    local text_h = FONT:getHeight() + 8

    local background = TextureGenerator.generateParchmentTexture(w, h)

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

    love.graphics.draw(background, x, y)

    love.graphics.setColor(unpack(TEXT_COLOR))
    love.graphics.print('COMBAT STATS', x + 10, y + 10)
    love.graphics.print(att_value, x + 10, y + text_h + 10)
    love.graphics.print(dmg_value, x + 10, y + text_h * 2 + 10)
    love.graphics.print(ac_value, x + 10, y + text_h * 3 + 10)
end

local function drawItemInfo(x, y, w, h)
    local background = TextureGenerator.generateParchmentTexture(w, h)
    love.graphics.draw(background, x, y)
end

-- TODO: need title bar and close button
Inventory.new = function(player)
    -- get components to draw items
    local equipment = player:getComponent(Equipment)
    local backpack = player:getComponent(Backpack)

    -- get components to draw combat stats
    local offense = player:getComponent(Offense)
    local defense = player:getComponent(Defense)

    -- the background & item containers
    local background = newBackground(500, 380)
    local container = TextureGenerator.generateContainerTexture()

    local frame = background.getFrame()

    -- equipment & backpack slots
    local equip_x, backpack_x = background.x + 16, background.x + 180
    local equip_y, backpack_y = background.y + 16, background.y + 16
    local slots = generateSlots(
        equipment, equip_x, background.y + 20,
        backpack, backpack_x, background.y + 20)    

    local stats_w, stats_h = mfloor(background.w / 2 - 20), 90
    local stats_y = background.y + background.h - stats_h

    local hover_slot_info = nil

    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()

        mx, my = mx / UI_SCALE, my / UI_SCALE

        hover_slot_info = nil

        for idx, slot in ipairs(slots) do
            -- TODO: slots should use frames (Rect) to simpify calculations
            local x1, x2, y1, y2 = slot.x, slot.x + TILE_SIZE, slot.y, slot.y + TILE_SIZE
            if mx > x1 and mx < x2 and my > y1 and my < y2 then
                hover_slot_info = {
                    idx = idx,
                    slot = slot,
                }
                break
            end
        end
    end

    local game = nil

    local enter = function(self, from)
        assert(getmetatable(from) == Game, 'invalid argument for "from", expected: "Game"')
        
        game = from
        game:showOverlay()

        -- TODO: maybe we don't need this 'hacky' way to change mouse visibility if we control 
        -- visiblity from Game class, instead of Pointer class
        love.mouse.setVisible(true)
    end

    local leave = function(self, to)
        game:hideOverlay()
        game = nil
    end

    local draw = function(self)
        -- draw game behind inventory        
        game:draw()

        -- draw inventory on top
        background.draw()

        love.graphics.print('EQUIPMENT', equip_x + 4, equip_y - 8)
        love.graphics.print('BACKPACK', backpack_x + 4, backpack_y - 8)

        for idx, slot in ipairs(slots) do           
            love.graphics.draw(container, slot.x, slot.y)

            if idx > 11 then
                drawItem(backpack:peek(slot.key), slot.x, slot.y)
            else
                drawItem(equipment:getItem(slot.key), slot.x, slot.y)
            end
        end

        local mid_x = WINDOW_W / 2
        local ox = mfloor((background.w / 2 - stats_w) / 3)
        drawCombatStats(equipment, offense, defense, mid_x - stats_w - ox, stats_y, stats_w, stats_h)        
        drawItemInfo(mid_x + ox, stats_y, stats_w, stats_h)

        if not hover_slot_info then return end

        love.graphics.setColor(unpack(TEXT_COLOR))

        local item = nil
        if hover_slot_info.idx > 11 then
            item = backpack:peek(hover_slot_info.idx - 11)
        else
            item = equipment:getItem(hover_slot_info.slot.key)
        end

        if item then
            local info = item:getComponent(Info)
            love.graphics.print(info:getName(), mid_x + ox + 10, stats_y + 10)
            local lines = lume.split(info:getDescription(), '\n')
            for idx, line in ipairs(lines) do
                love.graphics.print(string.upper(line), mid_x + ox + 10, stats_y + idx * 15 + 10)
            end
        end
    end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            Gamestate.pop()
        end
    end

    local mouseReleased = function(self, mx, my, mouse_btn)
        if not frame:contains(mx, my) then return Gamestate.pop() end

        if not (hover_slot_info and mouse_btn == 2) then return end

        if hover_slot_info.idx > 11 then
            print('try equip or use item from backpack')

            local item_idx = hover_slot_info.idx - 11

            local item = backpack:peek(item_idx)

            -- ignore empty slots
            if not item then return end

            -- equip item if possible
            local equippable = item:getComponent(Equippable)        
            if equippable then
                if equippable:equip(player) then
                    backpack:take(item_idx)
                end
            end
        else
            if backpack:isFull() then
                error('backpack reached max limit')
            end

            equipment:unequip(hover_slot_info.slot.key)
        end

        -- update game to show current health and energy after eating food, drinking potion, ...
        game:update(0)

        -- if player died after using a harmful item, hide inventory
        if not player:getComponent(Health):isAlive() then
            Gamestate.pop()
            Gamestate.update(0)
        end                
    end

    return setmetatable({
        mouseReleased   = mouseReleased,
        keyReleased     = keyReleased,
        update          = update,
        enter           = enter,
        leave           = leave,
        draw            = draw,
    }, Inventory)
end

return setmetatable(Inventory, {
    __call = function(_, ...) return Inventory.new(...) end,
})
