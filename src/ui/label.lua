--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor, mmin, mmax = math.floor, math.min, math.max

local Label = {}

Label.new = function(text, color, halign, valign)
    local text_info = {
        text    = text or '',
        width   = FONTS['default']:getWidth(text or ''),
        height  = StringHelper.getHeight(text or ''),
    }

    local frame = Rect(0)

    color = color or { 1.0, 1.0, 1.0, 1.0 }

    local update = function(self, dt) end

    local draw = function(self)
        local x, y, w, h = frame:unpack()
        
        -- valign: 'start', 'center', 'end'
        local oy = 0
        if valign == 'end' then
            oy = mmin(h - text_info.height, w)
        elseif valign == 'center' then
            oy = mmax(mfloor((h - text_info.height) / 2), 0)
        end

        -- halign: 'start', 'center', 'end'
        local ox = 0
        if halign == 'end' then
            ox = mmin(w - text_info.width, w)
        elseif halign == 'center' then
            ox = mmax(mfloor((w - text_info.width) / 2), 0)
        end

        love.graphics.setColor(unpack(color))
        love.graphics.print(text_info.text, x + ox, y + oy)
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 
    end

    local getFrame = function(self) return frame:unpack() end

    local getSize = function(self) return text_info.width, text_info.height end 

    local setText = function(self, text_) 
        text_info.text = text_ or ''
        text_info.width = FONTS['default']:getWidth(text_ or '')
        text_info.height = StringHelper.getHeight(text_ or '')
    end

    local getText = function(self) return text_info.text or '' end
    
    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getText     = getText,
        setText     = setText,
        getSize     = getSize,
        setFrame    = setFrame,
        getFrame    = getFrame,
    }, Label)
end

return setmetatable(Label, {
    __call = function(_, ...) return Label.new(...) end,
})
