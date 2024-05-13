--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, mmax = math.floor, math.max

local ResourceBar = {}

local SEGMENT_COUNT = 20

local QUAD_INFO = TableHelper.readOnly({
    ['health'] = { 324, 326 },
    ['energy'] = { 328, 330 },
})

local function generateBarTexture(texture, empty_quad, filled_quad, value)
    local quad_w, quad_h = select(3, empty_quad:getViewport())
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
    assert(QUAD_INFO[type] ~= nil, 'invalid argument for "type", expected "health" or "energy"')

    local frame = Rect(0)
    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local frames = QUAD_INFO[type]
    local empty_quad, filled_quad = quads[frames[1]], quads[frames[2]]
    local texture_idx = 0

    local textures = {}
    for i = 0, SEGMENT_COUNT do
        textures[i] = generateBarTexture(texture, empty_quad, filled_quad, i)
    end

    local resource = ((type == 'health') and 
        entity:getComponent(Health) or 
        entity:getComponent(Energy))

    local update = function(self)
        local current, total = resource:getValue()
        texture_idx = mfloor(current / total * SEGMENT_COUNT)
    end

    local draw = function(self) 
        local x, y = frame:unpack()        
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(textures[texture_idx], x, y)
    end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getSize = function(self) return select(3, empty_quad:getViewport()) end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        setFrame    = setFrame,
    }, ResourceBar)
end

return setmetatable(ResourceBar, {
    __call = function(_, ...) return ResourceBar.new(...) end,
})
