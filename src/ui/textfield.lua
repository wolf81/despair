--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local utf8 = require 'utf8'

local Textfield = {}

Textfield.new = function()
    local frame = Rect(0)

    local border = nil

    local contents = {
        text = '',
        frame = Rect(0),
        ox = 0,
    }
    
    local draw = function(self)
        local x, y, w, h = frame:unpack()

        love.graphics.draw(border, x, y)

        local text_x, text_y, text_w, text_h = contents.frame:unpack()
        love.graphics.setColor(0.0, 0.0, 0.0, 1.0)
        love.graphics.setScissor(x + text_x, y + text_y, text_w, text_h)
        love.graphics.push()
        love.graphics.translate(contents.ox, 0)
        love.graphics.print(contents.text, x + text_x, y + text_y)
        love.graphics.pop()
        love.graphics.setScissor()
    end

    local update = function(self, dt)
        local x, y, w, h = contents.frame:unpack()
        local text_w = FONTS['default']:getWidth(contents.text)
        if text_w > w then
            contents.ox = math.floor(w - text_w)
        else
            contents.ox = 0
        end
        contents.frame = Rect(x, y, w, h)
    end

    local setText = function(self, text) contents.text = text or '' end

    local getText = function(self) return contents.text end

    local getSize = function(self) 
        return FONTS['default']:getWidth(contents.text), FONTS['default']:getHeight() * FONTS['default']:getLineHeight() 
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 

        border = TextureGenerator.generateBorderTexture(w, h, { 1.0, 1.0, 1.0, 0.8 })

        local text_y = math.floor((h - FONTS['default']:getHeight()) / 2)
        local text_x = text_y        
        contents.frame = Rect(text_x, text_y, w - text_x * 2, h - text_y * 2)
    end

    local getFrame = function(self) return frame end

    local textInput = function(self, text) contents.text = contents.text .. text end

    local keyReleased = function(self, key, scancode)
        if key == 'backspace' then
            local byteoffset = utf8.offset(contents.text, -1)

            if byteoffset then
                self:setText(string.sub(contents.text, 1, byteoffset - 1))
            end
        end
    end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        setText     = setText,
        getText     = getText,
        getSize     = getSize,
        setFrame    = setFrame,
        getFrame    = getFrame,
        textInput   = textInput,
        keyReleased = keyReleased,
    }, Textfield)
end

return setmetatable(Textfield, {
    __call = function(_, ...) return Textfield.new(...) end,
})
