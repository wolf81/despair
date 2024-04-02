--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local M = {}

-- keep track of mouse position & coord, for target & visibility purposes
local mouse = {
    pos     = vector(0, 0),
    coord   = vector(0, 0),
}

-- generate image data from a quad on a texture
local function newImageData(texture, quad)
    local _, _, qw, qh = quad:getViewport()
    local canvas = love.graphics.newCanvas(qw, qh)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, quad)
    end)
    return canvas:newImageData()
end

-- initializer should be called when app starts
M.init = function()
    if not love.mouse.isCursorSupported() then return end

    -- create a mouse cursor from a quad
    local texture = TextureCache:get('uf_interface')
    assert(texture ~= nil, 'TextureCache is missing texture: "uf_interface"')
    local quads = QuadGenerator.generate(texture, 24, 24, 8, 16)
    local image_data = newImageData(texture, quads[272])
    local cursor = love.mouse.newCursor(image_data, 6, 6)

    -- and set the mouse cursor
    love.mouse.setCursor(cursor)
end

M.update = function(camera, level)
    local mx, my = love.mouse.getPosition()
    
    -- unhide mouse pointer if mouse moved and was hidden
    if not love.mouse.isVisible() and (mouse.pos.x ~= mx and mouse.pos.y ~= my) then 
        love.mouse.setVisible(true)
    end
    mouse.pos = vector(mx, my)

    -- convert mouse position to coords, so game can use for targeting purposes
    local x, y = camera:worldCoords(mx, my)
    mouse.coord = vector(mfloor(x / TILE_SIZE), mfloor(y / TILE_SIZE))
end

-- get the current mouse coordinate
M.getCoord = function() return mouse.coord end

return M
