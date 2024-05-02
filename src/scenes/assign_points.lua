--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local AssignPoints = {}

local function generateButtonTexture(title)
    return TextureGenerator.generateButtonTexture(80, 32, title)
end

AssignPoints.new = function(points_info, remaining)
    local frame = Rect(0)

    local overlay = Overlay()

    local from_scene = nil

    local update = function(self, dt)
        -- body
    end

    local draw = function(self)
        from_scene:draw()
        overlay:draw()
    end

    local enter = function(self, from) 
        from_scene = from

        overlay:fadeIn()
    end

    local leave = function(self, to)
        from_scene = nil
    end

    local setFrame = function(self, x, y, w, h) frame = Rect(x, y, w, h) end

    local getFrame = function(self) return frame:unpack() end

    local keyReleased = function(self, key, scancode)
        if Gamestate.current() == self and key == 'escape' then
            overlay:fadeOut(Gamestate.pop)
        end
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        if Gamestate.current() == self and not frame:contains(mx, my) then
            overlay:fadeOut(Gamestate.pop)
        end
    end

    return setmetatable({
        -- methods
        draw            = draw,
        enter           = enter,
        leave           = leave,
        update          = update,
        setFrame        = setFrame,
        getFrame        = getFrame,
        keyReleased     = keyReleased,
        mouseReleased   = mouseReleased,
    }, AssignPoints)
end

return setmetatable(AssignPoints, {
    __call = function(_, ...) return AssignPoints.new(...) end,
})
