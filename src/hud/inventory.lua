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
		table.insert(y_offsets, i * spacing + (i - 1) * size)
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

local function drawCombatStats(x, y, w, h)
	love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
	love.graphics.rectangle('line', x, y, w, h)	
end

Inventory.new = function(player)
	local w, h = 500, 410

	local equipment = player:getComponent(Equipment)

	local update = function(self, dt) 
		-- body
	end

	local draw = function(self, x, y)
		love.graphics.setColor(1.0, 0.0, 1.0, 0.5)
		love.graphics.rectangle('line', x, y, w, h)

		drawEquipment(x, y, 184, 300, equipment)
		drawBackpack(x + 184, y, 316, 300)
		drawCombatStats(x, y + 300, 184, 110)
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
