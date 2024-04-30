--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Chooser = {}

Chooser.new = function(...)
    local options = {...}

    local background = nil
    local frame = Rect(0)

    local draw = function(self)
        local x, y = frame:unpack()

        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(background, x, y)

        for idx, option in ipairs(options) do
            love.graphics.print(option, x + 10, y + 10 + (idx - 1) * 48)
        end
    end

    local update = function(self, dt)
        -- body
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h) 

        background = TextureGenerator.generateContainerTexture(w, h)
    end

    local getFrame = function(self) return frame end

    local getSize = function(self) return frame:getSize() end

    return setmetatable({
        -- methods
        draw        = draw,
        update      = update,
        getSize     = getSize,
        setFrame    = setFrame,
        getFrame    = getFrame,
    }, Chooser)
end

return setmetatable(Chooser, {
    __call = function(_, ...) return Chooser.new(...) end,
})
