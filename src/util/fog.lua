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

    -- keep track of fog alpha values for all tiles in level
    local fog_alpha = {}
    for y = 1, map_h do
        fog_alpha[y] = {}
        for x = 1, map_w do
            fog_alpha[y][x] = 1.0
        end
    end

    -- a set of tiles that have been discovered
    local revealed = {}

    -- a set of tiles that are currently visible, so in line of sight
    local visible = {}

    -- a set of tiles in current or previous drawing rect
    local active = {}

    -- previous and next drawing area rectangles
    local prev_rect, next_rect = Rect(0), Rect(0)

    local draw = function(self)
        local x, y, w, h = next_rect:unpack()
        for x = x, x + w do
            for y = y, y + h do
                love.graphics.setColor(1.0, 1.0, 1.0, fog_alpha[y][x])
                love.graphics.draw(texture, x * TILE_SIZE, y * TILE_SIZE)
            end
        end
    end

    local update = function(self, dt, x, y, w, h)
        -- constrain visible rectangle to map size
        local rect = Rect(mmax(x, 1), mmax(y, 1), mmin(w, map_w - x), mmin(h, map_h - y))

        -- if the visible rectangle has changed compared to previous update ...        
        if next_rect ~= rect then
            prev_rect, next_rect = next_rect, rect

            -- create a set of active tiles - tiles in current or previous drawing rect
            for _, rect in ipairs({ prev_rect, next_rect }) do
                local x, y, w, h = rect:unpack()
                for y = mmax(y, 1), mmin(y + h, map_h) do
                    for x = mmax(x, 1), mmin(x + w, map_w) do
                        active[getKey(x, y)] = { x, y }
                    end
                end
            end
        end

        -- animate fog tiles with fade-in or fade-out animation
        for key, info in pairs(active) do
            local x, y = unpack(info)
            local alpha = fog_alpha[y][x]
            if not visible[key] then
                -- show fog of war
                local to_alpha = revealed[getKey(x, y)] and 0.5 or 1.0
                alpha = mmin(alpha + dt * SPEED, to_alpha)
                if alpha == to_alpha then active[key] = nil end
            else
                -- hide fog of war
                alpha = mmax(alpha - dt * SPEED, 0.0)
                if alpha == 0.0 then active[key] = nil end
            end
            fog_alpha[y][x] = alpha            
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
