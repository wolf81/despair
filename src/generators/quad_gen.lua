--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local M = {}

M.generate = function(texture, quad_w, quad_h, ox, oy)
    ox = ox or 0
    oy = oy or 0

    local texture_w, texture_h = texture:getDimensions()
    local cols = mfloor((texture_w - ox) / quad_w)
    local rows = mfloor((texture_h - oy) / quad_h)

    local quads = {}

    for y = 0, rows - 1 do
        for x = 0, cols - 1 do
            quads[#quads + 1] = love.graphics.newQuad(
                ox + x * quad_w, 
                oy + y * quad_w, 
                quad_w,
                quad_h, 
                texture
            )
        end
    end

    return quads
end

return M
