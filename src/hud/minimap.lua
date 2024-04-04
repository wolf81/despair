--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Minimap = {}

Minimap.new = function(player)
    local key = 'uf_interface'
    local texture = TextureCache:get(key)
    local quads = QuadCache:get(key)

    local _, _, quad_w, quad_h = quads[270]:getViewport()

    local colors = ColorHelper.getColors(texture, quads[270], true)
    local fill_color = colors[1].color

    local update = function(self, dt)
        -- body
    end

    local draw_info = {
        [vector(0, 0)] = 270,
        [vector(1, 0)] = 271,
        [vector(2, 0)] = 271,
        [vector(3, 0)] = 271,
        [vector(4, 0)] = 275,
        [vector(0, 1)] = 278,
        [vector(4, 1)] = 272,
        [vector(0, 2)] = 278,
        [vector(4, 2)] = 272,
        [vector(0, 3)] = 278,
        [vector(4, 3)] = 272,
        [vector(0, 4)] = 280,
        [vector(1, 4)] = 277,
        [vector(2, 4)] = 277,
        [vector(3, 4)] = 277,
        [vector(4, 4)] = 279,

    }

    local draw = function(self, x, y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        for coord, quad_idx in pairs(draw_info) do
            local ox = coord.x * quad_w
            local oy = coord.y * quad_h
            love.graphics.draw(texture, quads[quad_idx], x + ox, y + oy)
        end

        love.graphics.setColor(unpack(fill_color))
        love.graphics.rectangle('fill', x + quad_w, y + quad_h, quad_w * 3, quad_h * 3)
    end

    local getSize = function()
        return quad_w * 5, quad_h * 5
    end

    return setmetatable({
        -- methods
        getSize = getSize,
        update  = update,
        draw    = draw,
    }, Minimap)
end

return setmetatable(Minimap, {
    __call = function(_, ...) return Minimap.new(...) end
})