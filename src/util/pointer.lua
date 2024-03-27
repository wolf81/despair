local mfloor = math.floor

local M = {}

local last_coord = vector(0, 0)

M.update = function(camera, level)
    local mx, my = love.mouse.getPosition()
    local x, y = camera:worldCoords(mx, my)
    local coord = vector(mfloor(x / TILE_SIZE), mfloor(y / TILE_SIZE)) 

    if coord ~= last_coord then last_coord = coord end
end

M.draw = function(camera, level)
    love.graphics.setColor(0.0, 0.0, 1.0, 1.0)
    love.graphics.rectangle('line', last_coord.x * TILE_SIZE, last_coord.y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

M.getCoord = function()
    return last_coord
end

return M
