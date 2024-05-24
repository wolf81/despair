--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Textview = {}

-- TODO: same as Chooser, add to global constants?
local DISABLED_ALPHA = 0.7
local SCROLLBAR_W = 20
local SCROLL_SPEED = 150

local MARGIN = 10

Textview.new = function()
    local frame = Rect(0)

    local background = nil

    local scrollbar = Scrollbar()

    local text = ''

    local is_enabled = true

    local content_h, content_y = 0, 0

    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, (is_enabled and 1.0 or DISABLED_ALPHA))
        love.graphics.draw(background, x, y)

        love.graphics.setScissor(x + 1, y + 1, w - 2, h - 2)
        love.graphics.push()
        love.graphics.translate(0, -content_y)
        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.print(text, x + MARGIN, y + MARGIN)
        love.graphics.pop()

        scrollbar:draw()

        love.graphics.setScissor()        
    end

    local update = function(self, dt)
        -- body
    end

    local getFrame = function(self) return frame:unpack() end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 
        background = TextureGenerator.generateParchmentTexture(w, h)        
        scrollbar:setFrame(x + w - SCROLLBAR_W, y, SCROLLBAR_W, h)
    end

    local setText = function(self, text_)
        text = text_ or ''

        content_h = StringHelper.getHeight(text) + MARGIN * 2
        content_y = 0
    end
    
    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        setText     = setText,
        getFrame    = getFrame,
        setFrame    = setFrame,
    }, Textview)
end

return setmetatable(Textview, {
    __call = function(_, ...) return Textview.new(...) end,
})
