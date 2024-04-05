--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local HumpCamera = require 'lib.hump.camera'

local mfloor = math.floor

local Camera = {}

Camera.new = function(x, y, scale)
    local camera = HumpCamera(x or 0, y or 0, scale or 1.0)
    local follow = true

    local draw = function(self, fn, x, y, w, h)
        camera:attach(x, y, w, h)
        fn()
        camera:detach()
    end

    local cam_offset = TILE_SIZE / 2
    local move = function(self, coord, duration)
        if not follow then return end

        local pos = coord * TILE_SIZE
        Timer.tween(duration, camera, { 
            x = mfloor(pos.x + cam_offset), 
            y = mfloor(pos.y + cam_offset),
        })
    end

    local shake = function(self, duration)
        local x, y = camera.x, camera.y
        follow = false

        -- shake the camera for one second
        Timer.during(duration, function()
            camera.x = x + love.math.random(-2, 2)
            camera.y = y + love.math.random(-2, 2)
        end, function()
            camera.x = x
            camera.y = y
            follow = true
        end)        
    end

    local worldCoords = function(self, ...)
        return camera:worldCoords(...)
    end

    return setmetatable({
        -- methods
        move        = move,
        shake       = shake,
        draw        = draw,
        worldCoords = worldCoords,
    }, Camera)
end

return setmetatable(Camera, { 
    __call = function(_, ...) return Camera.new(...) end,
})
