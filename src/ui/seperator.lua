local mfloor = math.floor

local Seperator = {}

Seperator.new = function()
    local frame = Rect(0, 0, 1, 0)

    local draw = function(self) 
        local x, y, w, h = frame:unpack()

        love.graphics.setColor(0.0, 0.0, 0.0, 0.7)
        love.graphics.line(x + mfloor(w / 2), y, x + mfloor(w / 2), y + h)
    end

    local update = function(self, dt) end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end    

    local getSize = function(self) return select(3, frame) end
    
    return setmetatable({
        -- methods
        setFrame    = setFrame,
        getSize     = getSize,
        update      = update,
        draw        = draw,
    }, Seperator)
end

return setmetatable(Seperator, {
    __call = function(_, ...) return Seperator.new(...) end,
})
