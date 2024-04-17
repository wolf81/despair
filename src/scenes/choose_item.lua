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

local function getImageButton(item)
    local def = EntityFactory.getDefinition(item.id)
    local texture = TextureCache:get(def.texture)
    local quads = QuadCache:get(def.texture)
    local quad_idx = def.anim[1]
    local image = getImage(texture, quads[quad_idx])
    return ImageButton(image, item.gid)
end

local function getFrame(anchor_x, anchor_y, item_count)
    local w, h = TILE_SIZE * item_count, TILE_SIZE
    local x = anchor_x - w / 2 + (w / item_count / 2) 
    local y = anchor_y - h - 1
    return { x, y, w, h }
end

ChooseItem.new = function(player, items, button)
    local game = nil

    local btn_x, btn_y = button:getFrame()
    local frame = getFrame(btn_x, btn_y, #items)
    local item_background = TextureGenerator.generatePanelTexture(TILE_SIZE, TILE_SIZE)

    local buttons = {}
    for idx, item in ipairs(items) do
        local button = getImageButton(item)
        local ox = (idx - 1) * TILE_SIZE
        button:setFrame(frame[1] + ox, frame[2], TILE_SIZE, TILE_SIZE)
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

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        local x, y, w, h = unpack(frame)
        if (mx < x) or (mx > x + w) or (my < y) or (my > y + h) then
            Gamestate.pop()
        end
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
