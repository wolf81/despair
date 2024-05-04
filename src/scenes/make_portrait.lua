local MakePortrait = {}

MakePortrait.new = function(gender, race, fn)
    local from_scene = nil
    local overlay = Overlay()

    local frame = Rect(0)

    local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local draw = function(self)
        from_scene:draw()
        overlay:draw()
    end

    local update = function(self, dt)
        -- body
    end

    local enter = function(self, from)
        from_scene = from
        overlay:fadeIn()
    end

    local leave = function(self, to)
        from_scene = nil
    end

    local setFrame = function(self, x, y, w, h) 
        frame = Rect(x, y, w, h)

        background = TextureGenerator.generateBorderTexture(w, h)
    end

    local getFrame = function(self) return frame:unpack() end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            dismiss()
        end
    end

    return setmetatable({
        -- methods
        draw        = draw,
        enter       = enter,
        leave       = leave,
        update      = update,
        setFrame    = setFrame,
        getFrame    = getFrame,
        keyReleased = keyReleased,
    }, MakePortrait)
end

return setmetatable(MakePortrait, {
    __call = function(_, ...) return MakePortrait.new(...) end,
})
