local mfloor = math.floor

local Inventory = {}

local function generateSlots(equipment, equip_x, equip_y, backpack, backpack_x, backpack_y)
    local slots = {}

    local spacing, size = 2, 48

    -- generate slots for equipment

    equip_slot_info = {
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
    }

    for i = 1, 11 do
        local x = (i == 1 or i == 11) and 2 or (1 + (i + 1) % 3)
        local y = (i == 11) and 5 or (i > 1) and mfloor((1 + i) / 3 + 1) or 1

        -- convert to pixel coords
        x = (x - 1) * (spacing + size)
        y = (y - 1) * (spacing + size)

        table.insert(slots, { 
            x   = equip_x + x,
            y   = equip_y + y,
            key = equip_slot_info[#slots + 1],
        })
    end

    -- generate slots for backpack

    local _, max_size = backpack:size()
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

local newBackground = function()
    local texture = TextureGenerator.generatePanelTexture(500, 390)
    local w, h = texture:getDimensions()
    local x = mfloor((WINDOW_W - w) / 2)
    local y = mfloor((WINDOW_H - h) / 2)

    local draw = function()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, x, y)
    end

    return {
        x = x,
        y = y,
        w = w,
        h = h,
        draw = draw,
    }
end

local function getDamageText(damage_info)
    local dice = ndn.dice(damage_info.weapon)
    local min, max = dice:range()
    return min + damage_info.bonus .. '-' .. max + damage_info.bonus
end

local function drawCombatStats(offense, defense, x, y)
    local text_h = FONT:getHeight() + 8

    local att_value = 'ATTACK BONUS: ' .. offense:getAttackValue()
    
    local _, damage_info = offense:getDamageValue()

    local dmg_value = 'DAMAGE:       ' .. getDamageText(damage_info)
    local ac_value  = 'ARMOR CLASS:  ' .. defense:getArmorValue()

    local y1 = y + h - 20 * 4

    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.print('COMBAT STATS', x, y1)
    love.graphics.print(att_value, x, y1 + text_h)
    love.graphics.print(dmg_value, x, y1 + text_h * 2)
    love.graphics.print(ac_value, x, y1 + text_h * 3)
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
    local background = newBackground()
    local container = TextureGenerator.generateContainerTexture()

    -- equipment & backpack slots
    local equip_x, backpack_x = background.x + 16, background.x + 180
    local equip_y, backpack_y = background.y + 16, background.y + 16
    local slots = generateSlots(
        equipment, equip_x, background.y + 20,
        backpack, backpack_x, background.y + 20)

    local stats_y = background.y + background.h - 16

    local hover_slot_info = nil

    local update = function(self, dt)
        local mx, my = love.mouse.getPosition()

        hover_slot_info = nil

        for idx, slot in ipairs(slots) do
            local x1, x2, y1, y2 = slot.x, slot.x + 48, slot.y, slot.y + 48
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

        drawCombatStats(offense, defense, equip_x + 4, stats_y)
    end

    local keyPressed = function(self, key, scancode)
        if key == 'i' then Gamestate.pop() end
    end

    local mouseReleased = function(self, x, y, mouse_btn)
        if not (hover_slot_info and mouse_btn == 2) then return end

        if hover_slot_info.idx > 11 then
            print('try equip or use item from backpack')

            local item_idx = hover_slot_info.idx - 11

            local item = backpack:peek(item_idx)

            -- TODO: how to easily check if item type is equippable? 
            if item.type == 'weapon' or item.type == 'armor' or item.type == 'necklace' or item.type == 'ring' then
                item = backpack:take(item_idx)
                equipment:equip(item)
            end
        else
            if backpack:isFull() then
                error('backpack reached max limit')
            end

            equipment:unequip(hover_slot_info.slot.key)


            print('try to move item to backpack')
        end
    end

    return setmetatable({
        mousereleased   = mouseReleased,
        keypressed      = keyPressed,
        update          = update,
        enter           = enter,
        leave           = leave,
        draw            = draw,
    }, Inventory)
end

return setmetatable(Inventory, {
    __call = function(_, ...) return Inventory.new(...) end,
})
