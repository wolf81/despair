local View = {}

View.new = function(color)
    local frame = { 0, 0, 0, 0 }

    local draw = function(self)
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle('fill', unpack(frame))
    end

    local setFrame = function(self, x, y, w, h)
        frame = { x,y, w, h }
    end

    local update = function(self, dt) end
    
    return setmetatable({
        setFrame = setFrame,
        update = update,
        draw = draw,
    }, View)
end

return setmetatable(View, {
    __call = function(_, ...) return View.new(...) end,
})
