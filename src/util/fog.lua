--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local Fog = {}

local getKey = function(x, y)
    return x .. ':' .. y
end

Fog.new = function(width, height) 
   local visible = {}
    local revealed = {}
    local last_visible = {}

    local draw = function(self, ox, oy)
        local x = mfloor(ox / TILE_SIZE)
        local y = mfloor(oy / TILE_SIZE)        
        
        for x = x, x + width do
            for y = y, y + height do
                local key = getKey(x, y)
                if not visible[key] then
                    love.graphics.setColor(0.0, 0.0, 0.0, revealed[key] and 0.5 or 1.0)
                    love.graphics.rectangle('fill', x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
                end
            end
        end

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end

    local reveal = function(self, x, y)
        local key = getKey(x, y)
        visible[key] = true
        revealed[key] = true        
    end

    local isVisible = function(self, x, y)
        return visible[getKey(x, y)] == true
    end

    local wasVisible = function(self, x, y)
        return last_visible[getKey(x, y)] == true
    end

    local cover = function(self)
        last_visible = visible
        visible = {}
    end

    return setmetatable({
        -- methods
        draw        = draw,
        cover       = cover,
        reveal      = reveal,
        isVisible   = isVisible,
        wasVisible  = wasVisible,
    }, Fog)
end

return setmetatable(Fog, {
    __call = function(_, ...) return Fog.new(...) end,
})
