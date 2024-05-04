--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Portrait = {}

Portrait.new = function(scale)
    scale = scale or 1

    local texture = TextureCache:get('uf_portraits')
    local quads = QuadCache:get('uf_portraits')

    local quad_w, quad_h = select(3, quads[1]:getViewport())
    local frame = Rect(0, 0, quad_w * scale, quad_h * scale)

    local background_idx, border_idx = quads[6], quads[7]

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, background_idx, x, y, 0, scale, scale)
        love.graphics.draw(texture, border_idx, x, y, 0, scale, scale)
    end

    local update = function(self)
    end

    local getFrame = function(self) return frame end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getSize = function(self) return frame:getSize() end
    
    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        getFrame    = getFrame,
        setFrame    = setFrame,        
    }, Portrait)
end

return setmetatable(Portrait, {
    __call = function(_, ...) return Portrait.new(...) end,
})
