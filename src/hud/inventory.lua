--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Inventory = {}

local function drawItemContainer(x, y, item)	
	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

	local texture = TextureCache:get('uf_interface')
	local quads = QuadCache:get('uf_interface')

	love.graphics.draw(texture, quads[334], x, y)
	love.graphics.draw(texture, quads[335], x + 16, y)
	love.graphics.draw(texture, quads[338], x + 32, y)

	love.graphics.draw(texture, quads[336], x, y + 16)
	love.graphics.draw(texture, quads[341], x + 32, y + 16)

	love.graphics.draw(texture, quads[339], x, y + 32)
	love.graphics.draw(texture, quads[340], x + 16, y + 32)
	love.graphics.draw(texture, quads[343], x + 32, y + 32)

	local color_info = ColorHelper.getColors(texture, quads[334], true)[1]
	love.graphics.setColor(color_info.color)
	love.graphics.rectangle('fill', x + 16, y + 16, 16, 16)

	if item ~= nil then
		local def = EntityFactory.getDefinition(item.id)
		local texture = TextureCache:get(def.texture)
		local quads = QuadCache:get(def.texture)
		local frame = def.anim[1]

		love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
		love.graphics.draw(texture, quads[frame], x, y)
	end
end

local function drawBackpack(backpack, x, y, w, h)
	local spacing = 2

	local ox = 48 + spacing
	local oy = 48 + spacing

	local grid_w = ox * 6
	local grid_h = ox * 5

	local x1, x2 = x, x + ox * 5
	local y1, y2 = y + 25, y + ox * 4 + 25

	local idx = 1
	for y = y1, y2, ox do
		for x = x1, x2, ox do
			drawItemContainer(x, y, backpack:peek(idx))
			idx = idx + 1
		end		
	end

	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.print('BACKPACK', x, y + 10)
end

local function drawEquipment(equipment, x, y, w, h) 
	local spacing, size = 2, 48

	local x_offsets = {}
	for i = 1, 3 do
		table.insert(x_offsets, i * spacing + (i - 1) * size + 5)
	end
	local x1, x2, x3 = unpack(x_offsets)

	local y_offsets = {}
	for i = 1, 5 do
		table.insert(y_offsets, i * spacing + (i - 1) * size + 25)
	end
	local y1, y2, y3, y4, y5 = unpack(y_offsets)

	drawItemContainer(x + x2, y + y1)
	drawItemContainer(x + x1, y + y2, equipment:getItem('mainhand'))
	drawItemContainer(x + x2, y + y2)
	drawItemContainer(x + x3, y + y2, equipment:getItem('offhand'))
	drawItemContainer(x + x1, y + y3)
	drawItemContainer(x + x2, y + y3, equipment:getItem('chest'))
	drawItemContainer(x + x3, y + y3)
	drawItemContainer(x + x1, y + y4)
	drawItemContainer(x + x2, y + y4)
	drawItemContainer(x + x3, y + y4)
	drawItemContainer(x + x2, y + y5)

	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.print('EQUIPMENT', x + 10, y + 10)
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

	local update = function(self, dt) 
		local mx, my = love.mouse.getPosition()
		-- TODO: on mouse over show information? Or on left-click
		-- TODO: use right mouse click or drag to equip?
	end

	local draw = function(self, x, y)
		love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
		love.graphics.draw(background, x, y)

		drawEquipment(equipment, x, y, 184, 320)
		drawBackpack(backpack, x + 184, y, 316, 320)
		drawCombatStats(player, x, y + 304, 184, 90)
	end

	local getSize = function(self) 
		return w, h 
	end
	
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
