local ChooseItem = {}

local function getImage(texture, quad)
    local _, _, quad_w, quad_h = quad:getViewport()
    local canvas = love.graphics.newCanvas(quad_w, quad_h)
    canvas:renderTo(function()
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, quad, 0, 0) 
    end)

    return canvas
end

ChooseItem.new = function(player, items, button)
    local game = nil

    local btn_x, btn_y = button:getFrame()

    local item_background = TextureGenerator.generatePanelTexture(TILE_SIZE, TILE_SIZE)
    local w, h = TILE_SIZE * #items, TILE_SIZE
    local x = btn_x - w / 2 + (w / #items / 2) 
    local y = btn_y - h - 1

    local buttons = {}

    for idx, item in ipairs(items) do
        local def = EntityFactory.getDefinition(item.id)
        local texture = TextureCache:get(def.texture)
        local quads = QuadCache:get(def.texture)
        local frame = def.anim[1]
        local image = getImage(texture, quads[frame])
        local button = ImageButton(image, item.gid)
        local ox = (idx - 1) * TILE_SIZE
        button:setFrame(x + ox, y, TILE_SIZE, TILE_SIZE)
        table.insert(buttons, button)
    end

    local enter = function(self, from)
        game = from

        button:setSelected(true)
    end

    local leave = function(self, to)
        button:setSelected(false)

        game = nil
    end

    local draw = function(self)
        game:draw()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        for _, button in ipairs(buttons) do
            local btn_x, btn_y = button:getFrame()
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            love.graphics.draw(item_background, btn_x, btn_y)
            button:draw()
        end
    end

    local update = function(self, dt)
        for _, button in ipairs(buttons) do
            button:update(dt)
        end
    end

    local keyReleased = function(self, key, scancode)
        if key == "escape" then
            Gamestate.pop()
        end
    end

    local mouseReleased = function(self, x, y, button, istouch, presses)
        Gamestate.pop()
    end
    
    return setmetatable({
        -- methods
        draw            = draw,
        enter           = enter,
        leave           = leave,
        update          = update,
        keyReleased     = keyReleased,
        mouseReleased   = mouseReleased,
    }, ChooseItem)
end

return setmetatable(ChooseItem, {
    __call = function(_, ...) return ChooseItem.new(...) end,
})
