--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Inventory = {}

local function generateSlots(equipment, equip_x, equip_y, backpack, backpack_x, backpack_y)
	local slots = {}

	local spacing, size = 2, 48

	-- generate slots for equipment

	equip_slot_info = {
		[2] = 'mainhand',
		[4] = 'offhand',
		[6] = 'chest',
	}

	for i = 1, 11 do
		x = (i == 1 or i == 11) and 2 or (1 + (i + 1) % 3)
		y = (i == 11) and 5 or (i > 1) and mfloor((1 + i) / 3 + 1) or 1

		print(i, x, y)

		local i = #slots
		local ox = (x - 1) * (spacing + size)
		local oy = (y - 1) * (spacing + size)

		table.insert(slots, { 
			x = equip_x + ox,
			y = equip_y + oy,
			key = equip_slot_info[i],
		})
	end

	-- generate slots for backpack

	local _, max_size = backpack:size()
	for i = 1, max_size do
		local y = backpack_y + mfloor((i - 1) / 6) * (size + spacing)
		local x = backpack_x + ((i  - 1) % 6) * (size + spacing)
		table.insert(slots, { x = x, y = y, key = i })
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

local function getDamageText(damage_info)
	local dice = ndn.dice(damage_info.weapon)
	local min, max = dice:range()
	return min + damage_info.bonus .. '-' .. max + damage_info.bonus
end

local function drawCombatStats(player, x, y, w, h)
	local offense = player:getComponent(Offense)
	local defense = player:getComponent(Defense)

	local text_h = FONT:getHeight() + 8

	local att_value = 'ATTACK BONUS: ' .. offense:getAttackValue()
	
	local _, damage_info = offense:getDamageValue()

	local dmg_value = 'DAMAGE:       ' .. getDamageText(damage_info)
	local ac_value  = 'ARMOR CLASS:  ' .. defense:getArmorValue()

	local y1 = y + h - 20 * 4

	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.print('COMBAT STATS', x + 10, y1)
	love.graphics.print(att_value, x + 10, y1 + text_h)
	love.graphics.print(dmg_value, x + 10, y1 + text_h * 2)
	love.graphics.print(ac_value, x + 10, y1 + text_h * 3)
end

Inventory.new = function(player)
	local w, h = 496, 384

	local equipment = player:getComponent(Equipment)
	local backpack = player:getComponent(Backpack)

	local background = TextureGenerator.generatePanelTexture(w, h)

	local equip_x, equip_y = 5, 25
	local backpack_x, backpack_y = 184, 25

	local slots = generateSlots(
		equipment, equip_x, equip_y, 
		backpack, backpack_x, backpack_y)

	local update = function(self, dt) 
		local mx, my = love.mouse.getPosition()

		mx = mx / SCALE
		my = my / SCALE

		for idx, slot in ipairs(slots) do
			local x1, x2, y1, y2 = slot.x, slot.x + 48, slot.y, slot.y + 48
			if mx > x1 and mx < x2 and my > y1 and my < y2 then
				print('hovering over slot ' .. idx)
			end
		end

		-- TODO: on mouse over show information? Or on left-click
		-- TODO: use right mouse click or drag to equip?
	end

	local container_image = TextureGenerator.generateContainerTexture()

	local draw = function(self, x, y)
		love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
		love.graphics.draw(background, x, y)

		love.graphics.print('EQUIPMENT', equip_x, y + 10)
		love.graphics.print('BACKPACK', backpack_x, y + 10)
		for idx, slot in ipairs(slots) do			
			love.graphics.draw(container_image, x + slot.x, y + slot.y)

			if idx > 11 then
				drawItem(backpack:peek(slot.key), x + slot.x, y + slot.y)
			else
				drawItem(equipment:getItem(slot.key), x + slot.x, y + slot.y)
			end
		end

		drawCombatStats(player, x, y + 304, 184, 90)
	end

	local getSize = function(self) return w, h end
	
	return setmetatable({
		-- methods
		getSize = getSize,
		update 	= update,
		draw 	= draw,
	}, Inventory)
end

return setmetatable(Inventory, {
	__call = function(_, ...) return Inventory.new(...) end,
})
