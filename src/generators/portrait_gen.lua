--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local lrandom = love.math.random

local M = {}

local FACE_INDICES = { 47, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 65, 65, }

local HAIR_INDICES = { 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
    46, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, }

local HELM_INDICES = {
    ['fighter'] = { 66, },
    ['cleric']  = { 70, },
    ['rogue']   = { 67, 68, 69, },
    ['mage']    = { 71, 72, }
}
local ARMOR_INDICES = {
    ['fighter'] = { 1, 2, 3, 4, },
    ['cleric']  = { 14, 15, 16, },
    ['rogue']   = { 125, 126, 127, },
    ['mage']    = { 17, 18, 116, 117, 118 }
}
local ACCESSORY_INDICES = { 8, 9, 10, 11, 12, 13, 19, 20, 21, 22, 23, 24, 25, 26, }

local BEARD_INDICES = { 76, 77, 78, 79, 80, 87, 88, 89, 90, 105, 106, 107, 108, 109, 110 }

M.generate = function(player)
    local key = 'uf_portraits'
    local texture = TextureCache:get(key)
    local quads = QuadCache:get(key)

    -- TODO: adjust clothes, accessories for player race and/or class

    local face_idx = lrandom(51, 65)

    local hair_idx, helm_idx = 200, 200

    if lrandom(1, 3) > 1 then
        local helm_indices = HELM_INDICES[player.class]
        helm_idx = helm_indices[lrandom(#helm_indices)]
    elseif lrandom(1, 2) == 1 then
        hair_idx = HAIR_INDICES[lrandom(#HAIR_INDICES)]
    end

    local armor_indices = ARMOR_INDICES[player.class]
    local armor_idx = armor_indices[lrandom(#armor_indices)]

    local beard_idx = 200
    if lrandom(1, 4) > 1 then
        beard_idx = BEARD_INDICES[lrandom(#BEARD_INDICES)]
    end

    -- TODO: add accesories

    local _, _, quad_w, quad_h = quads[1]:getViewport()

    local canvas = love.graphics.newCanvas(quad_w, quad_h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 0.8)
        love.graphics.draw(texture, quads[6])
        love.graphics.draw(texture, quads[face_idx])
        love.graphics.draw(texture, quads[clothes_idx])
        love.graphics.draw(texture, quads[hair_idx])
        love.graphics.draw(texture, quads[beard_idx])
        love.graphics.draw(texture, quads[helm_idx])
        love.graphics.draw(texture, quads[7])
    end)

    return love.graphics.newImage(canvas:newImageData())
end

return M
