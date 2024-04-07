local mfloor = math.floor

local Inventory = {}

local function drawItem(item, x, y)
	local def = EntityFactory.getDefinition(item.id)
	local texture = TextureCache:get(def.texture)
	local quads = QuadCache:get(def.texture)
	local frame = def.anim[1]
	love.graphics.draw(texture, quads[frame], x, y)
end

local function drawBackpack(x, y, w, h)
	love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
	love.graphics.rectangle('line', x, y, w, h)

	local grid_w = 48 * 6
	local grid_h = 48 * 5

	local x1 = x + mfloor((w - grid_w) / 2)
	local x2 = x1 + grid_w
	local y1 = y + 10 + 20
	local y2 = y1 + grid_h

	for y = y1, y2 - 48, 48 do
		for x = x1, x2 - 48, 48 do
			love.graphics.rectangle('line', x, y, 48, 48)
		end		
	end

	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.print('BACKPACK', x + 10.5, y + 10.5)
end

local function drawEquipment(x, y, w, h, equipment) 
	love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
	love.graphics.rectangle('line', x, y, w, h)

	local spacing, size = 10, 48

	local x_offsets = {}
	for i = 1, 3 do
		table.insert(x_offsets, i * spacing + (i - 1) * size)
	end
	local x1, x2, x3 = unpack(x_offsets)

	local y_offsets = {}
	for i = 1, 5 do
		table.insert(y_offsets, i * spacing + (i - 1) * size + 20)
	end
	local y1, y2, y3, y4, y5 = unpack(y_offsets)

	love.graphics.rectangle('line', x + x2, y + y1, size, size)
	love.graphics.rectangle('line', x + x1, y + y2, size, size)
	love.graphics.rectangle('line', x + x2, y + y2, size, size)
	love.graphics.rectangle('line', x + x3, y + y2, size, size)
	love.graphics.rectangle('line', x + x1, y + y3, size, size)
	love.graphics.rectangle('line', x + x2, y + y3, size, size)
	love.graphics.rectangle('line', x + x3, y + y3, size, size)
	love.graphics.rectangle('line', x + x1, y + y4, size, size)
	love.graphics.rectangle('line', x + x2, y + y4, size, size)
	love.graphics.rectangle('line', x + x3, y + y4, size, size)
	love.graphics.rectangle('line', x + x2, y + y5, size, size)

	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

	love.graphics.print('EQUIPMENT', x + 10.5, y + 10.5)

	local item = equipment:getItem('mainhand')
	if item ~= nil then	
		drawItem(item, x + x1, y + y2)
	end

	item = equipment:getItem('offhand')
	if item ~= nil then	
		drawItem(item, x + x3, y + y2)
	end

	item = equipment:getItem('chest')
	if item ~= nil then	
		drawItem(item, x + x2, y + y3)
	end
end

local function getDamageText(damage_info)
	local dice = ndn.dice(damage_info.weapon)
	local min, max = dice:range()
	return min + damage_info.bonus .. '-' .. max + damage_info.bonus
end

local function drawCombatStats(player, x, y, w, h)
	local offense = player:getComponent(Offense)
	local defense = player:getComponent(Defense)

	love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
	love.graphics.rectangle('line', x, y, w, h)	

	local text_h = FONT:getHeight()

	local att_value = 'ATTACK BONUS: ' .. offense:getAttackValue()
	
	local _, damage_info = offense:getDamageValue()

	local dmg_value = 'DAMAGE:       ' .. getDamageText(damage_info)
	local ac_value  = 'ARMOR CLASS:  ' .. defense:getArmorValue()

	local y1 = y + h - 20 * 4

	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.print('COMBAT STATS', x + 10.5, y1 - 0.5)
	love.graphics.print(att_value, x + 10.5, y1 + 20.5)
	love.graphics.print(dmg_value, x + 10.5, y1 + 40.5)
	love.graphics.print(ac_value, x + 10.5, y1 + 60.5)
end

Inventory.new = function(player)
	local w, h = 500, 410

	local equipment = player:getComponent(Equipment)

	local update = function(self, dt) 
		-- body
	end

	local draw = function(self, x, y)
		love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
		love.graphics.rectangle('fill', x + 0.5, y + 0.5, w, h)

		drawEquipment(x + 0.5, y + 0.5, 184, 320, equipment)
		drawBackpack(x + 184 + 0.5, y + 0.5, 316, 320)
		drawCombatStats(player, x + 0.5, y + 320 + 0.5, 184, 90)
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
