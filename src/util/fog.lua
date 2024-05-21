--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, mmin, mmax = math.floor, math.min, math.max

local Fog = {}

local SPEED = 2.0

local function getKey(x, y) return x .. ':' .. y end

Fog.new = function(map_w, map_h) 
    local texture = TextureGenerator.generateColorTexture(TILE_SIZE, TILE_SIZE, { 
        0.0, 0.0, 0.0, 1.0 
    })

    local fog = {}
    for y = 1, map_h do
        fog[y] = {}
        for x = 1, map_w do
            fog[y][x] = { alpha = 1.0 }
        end
    end

    local revealed, visible, active = {}, {}, {}

    local prev_rect, next_rect = Rect(1, 1, 0, 0), Rect(1, 1, 0, 0)

    local draw = function(self)
        local x, y, w, h = next_rect:unpack()
        for x = x, x + w do
            for y = y, y + h do
                love.graphics.setColor(1.0, 1.0, 1.0, fog[y][x].alpha)
                love.graphics.draw(texture, x * TILE_SIZE, y * TILE_SIZE)
            end
        end
    end

    local update = function(self, dt, x, y, w, h)
        local rect = Rect(mmax(x, 1), mmax(y, 1), mmin(w, map_w - x), mmin(h, map_h - y))
        
        if next_rect ~= rect then
            prev_rect = next_rect
            next_rect = rect

            -- TODO: perhaps be be optimized by just comparing points from next rect with previous
            local x1, y1, w1, h1 = prev_rect:unpack()
            local x2, y2, w2, h2 = next_rect:unpack()
            w1 = mmin(x1 + w1, map_w - x1)
            h1 = mmin(y1 + h1, map_h - y1)
            w2 = mmin(x2 + w2, map_w - x2)
            h2 = mmin(y2 + h2, map_h - y2)
            
            x1 = mmin(x1, x2)
            y1 = mmin(y1, y2)
            x2 = mmax(x1 + w1, x2 + w2)
            y2 = mmax(y1 + h1, y2 + h2)

            for y = y1, y2 do
                for x = x1, x2 do                    
                    local key = getKey(x, y)
                    if not visible[key] then
                        active[key] = { x, y, 'fade-in' }
                    else
                        active[key] = { x, y, 'fade-out' }
                    end
                end
            end
        end

        for key, info in pairs(active) do
            local x, y, mode = unpack(info)
            local alpha = fog[y][x].alpha
            if mode == 'fade-in' then
                local to_alpha = revealed[getKey(x, y)] and 0.5 or 1.0
                alpha = mmin(alpha + dt * SPEED, to_alpha)
                if alpha == to_alpha then active[key] = nil end
            else
                alpha = mmax(alpha - dt * SPEED, 0.0)
                if alpha == 0.0 then active[key] = nil end
            end
            fog[y][x].alpha = alpha            
        end
    end

    local reveal = function(self, x, y)
        if x > 0 and x < map_w and y > 0 and y < map_h then
            local key = getKey(x, y)
            revealed[key] = true
            visible[key] = true
        end
    end

    local isVisible = function(self, x, y) return visible[getKey(x, y)] end

    local cover = function(self) visible = {} end

    return setmetatable({
        -- methods
        draw        = draw,
        cover       = cover,
        reveal      = reveal,
        update      = update,
        isVisible   = isVisible,
    }, Fog)
end

return setmetatable(Fog, {
    __call = function(_, ...) return Fog.new(...) end,
})
