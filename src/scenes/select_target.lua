--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mfloor = math.floor

local SelectTarget = {}

SelectTarget.new = function(entity)
    local frame = Rect(0)

    local game, ability = nil, nil

    local coord = vector(-1, -1)

    local update = function(self, dt)
        game:update(dt)
    end

    local draw = function(self)
        game:draw()

        -- crop drawing outside of visible frame, to prevent drawing over action bar & side panel
        love.graphics.setScissor(frame:unpack())

        love.graphics.setColor(1.0, 0.0, 1.0, 0.8)
        love.graphics.rectangle('line', coord.x * TILE_SIZE - 32, coord.y * TILE_SIZE + 32, TILE_SIZE, TILE_SIZE)

        -- reset crop area
        love.graphics.setScissor()
    end

    local setTargetable = function(self, x, y, range)
        x1, x2 = x - range, x + range
        y1, y2 = y - range, y + range
    end

    local setFrame = function(self, x, y, w, h)
        frame = Rect(x, y, w, h)
    end

    local mouseMoved = function(self, mx, my)
        coord = vector(mfloor((mx + TILE_SIZE / 2) / TILE_SIZE), mfloor((my - TILE_SIZE / 2 - 8) / TILE_SIZE))
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        if button == 2 then Gamestate.pop() end
        -- print('mouseReleased', mx, my, button)
    end

    -- ability can be a class ability, item (wand), spell ...
    local enter = function(self, from, ability)
        assert(getmetatable(from) == Game, 'invalid argument for "from", expected: "Game"')

        print('ab', ability.name)

        game, ability = from, ability

        entity:getComponent(Control):setEnabled(false)
        game:setActionsEnabled(false)
    end

    local leave = function(self, to)
        print('leave', from)

        entity:getComponent(Control):setEnabled(true)
        game:setActionsEnabled(true)

        game, ability = nil, nil
    end

    local keyReleased = function(self, key, scancode)        
        if Gamestate.current() == self and key == "escape" then
            Gamestate.pop()
        end
    end

    return setmetatable({
        mouseReleased   = mouseReleased,
        keyReleased     = keyReleased,
        mouseMoved      = mouseMoved,
        setFrame        = setFrame,
        update          = update,
        enter           = enter,
        leave           = leave,
        draw            = draw,
    }, SelectTarget)
end

return setmetatable(SelectTarget, {
    __call = function(_, ...) return SelectTarget.new(...) end,
})
