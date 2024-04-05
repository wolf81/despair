local Inventory = {}

Inventory.new = function(player)
	local w, h = 480, 200

	local update = function(self, dt) 
	end

	local draw = function(self, x, y)
		love.graphics.setColor(1.0, 0.0, 1.0, 1.0)
		love.graphics.rectangle('line', x, y, w, h)
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
