local mfloor, mmax = math.floor, math.max

local HealthBar = {}

-- call preload to generate 11 different bars, from empty (0) to full (10)
local HealthBars = {
    [0] = nil,
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
    [7] = nil,
    [8] = nil,
    [9] = nil,
    [10] = nil,
}

local function renderBar(texture, empty_quad, filled_quad, value)
    local _, _, quad_w, quad_h = empty_quad:getViewport()
    local canvas = love.graphics.newCanvas(TILE_SIZE, quad_h)
    local x = mfloor(mmax((TILE_SIZE - quad_w) / 2, 0))

    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 0.0, 0.0, 1.0)
        love.graphics.draw(texture, empty_quad, x, 0)
        love.graphics.setScissor(x, 0, quad_w * (value / 10), quad_h)
        love.graphics.draw(texture, filled_quad, x, 0)
        love.graphics.setScissor()
    end)

    return love.graphics.newImage(canvas:newImageData())
end

HealthBar.preload = function()
    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local empty_quad, filled_quad = quads[255], quads[254]

    for i = 0, 10 do
        HealthBars[i] = renderBar(texture, empty_quad, filled_quad, i)
    end
end

HealthBar.new = function(entity, def, alpha)
    local health = entity:getComponent(Health)
    assert(health ~= nil, 'missing component: "Health"')

    local bar_idx = 10

    local update = function(self)
        local current, max = health:getValue()
        bar_idx = mfloor(current / max * 10)
    end

    local draw = function(self, alpha) 
        local pos = entity.coord * TILE_SIZE
        love.graphics.setColor(1.0, 1.0, 1.0, alpha or 1.0)
        love.graphics.draw(HealthBars[bar_idx], mfloor(pos.x), mfloor(pos.y))
    end

    return setmetatable({
        -- methods
        update  = update,
        draw    = draw,
    }, HealthBar)
end

return setmetatable(HealthBar, {
    __call = function(_, ...) return HealthBar.new(...) end
})
