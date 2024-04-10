--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor, mmax = math.floor, math.max
local SEGMENT_COUNT = 20

local ResourceBar = {}

local quad_info = {
    ['health'] = { 354, 356 },
    ['energy'] = { 388, 390 },
}

local function generateBarTexture(texture, empty_quad, filled_quad, value)
    local _, _, quad_w, quad_h = empty_quad:getViewport()
    local canvas = love.graphics.newCanvas(quad_w, quad_h)

    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, empty_quad, 0, 0)
        love.graphics.setScissor(0, 0, quad_w * (value / SEGMENT_COUNT), quad_h)
        love.graphics.draw(texture, filled_quad, 0, 0)
        love.graphics.setScissor()
    end)

    return love.graphics.newImage(canvas:newImageData())
end

ResourceBar.new = function(entity, type)
    assert(entity ~= nil, 'missing argument: "entity"')
    assert(type ~= nil, 'missing argument: "type"')
    assert(quad_info[type] ~= nil, 'invalid argument for "type", expected "health" or "energy"')

    local textures = {}

    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local frames = quad_info[type]
    local empty_quad, filled_quad = quads[frames[1]], quads[frames[2]]
    local texture_idx = 0
    local _, _, w, h = empty_quad:getViewport()

    for i = 0, SEGMENT_COUNT do
        textures[i] = generateBarTexture(texture, empty_quad, filled_quad, i)
    end

    local resource = nil
    if type == 'health' then
        resource = entity:getComponent(Health)
    else
        resource = entity:getComponent(Energy)
    end

    local update = function(self)
        local current, total = resource:getValue()
        texture_idx = mfloor(current / total * SEGMENT_COUNT)
    end

    local draw = function(self, x, y) 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(textures[texture_idx], x, y)
    end

    local getSize = function() return w, h end

    return setmetatable({
        draw    = draw,
        update  = update,
        getSize = getSize,
    }, ResourceBar)
end

return setmetatable(ResourceBar, {
    __call = function(_, ...) return ResourceBar.new(...) end,
})
