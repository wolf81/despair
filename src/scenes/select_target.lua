--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local SelectTarget = {}

SelectTarget.new = function(entity)
    local frame = Rect(0)

    local game, ability = nil, nil

    -- offsets used for drawing the target indicator
    local ox, oy = 0, 0

    -- coord used for target indicator, only drawn if not nil
    local coord = nil

    local update = function(self, dt)
        game:update(dt)

        -- calculate level coord for mouse position
        local mx, my = love.mouse.getPosition()
        local level = game:getDungeon():getLevel()
        local level_coord = level:getCoord(mx, my) 

        if level_coord and level:isVisible(level_coord) then
            -- calculate camera coord for mouse position
            coord = vector(mfloor((mx - ox) / TILE_SIZE), mfloor((my - oy) / TILE_SIZE))
        else
            coord = nil
        end
    end

    local draw = function(self)
        game:draw()

        if not coord then return end

        -- crop drawing outside of visible frame, to prevent drawing over action bar & side panel
        love.graphics.setScissor(frame:unpack())

        love.graphics.setColor(1.0, 0.0, 1.0, 0.8)
        love.graphics.rectangle('line', coord.x * TILE_SIZE + ox, coord.y * TILE_SIZE + oy, TILE_SIZE, TILE_SIZE)

        -- reset crop area
        love.graphics.setScissor()
    end

    local setFrame = function(self, x, y, w, h)
        frame = Rect(x, y, w, h)

        ox = -w % TILE_SIZE - TILE_SIZE
        oy = -h % TILE_SIZE
    end

    local mouseReleased = function(self, mx, my, button, istouch, presses)
        if button ~= 2 then
            local level = game:getDungeon():getLevel()
            local target_coord = level:getCoord(mx, my)

            local usable = ability:getComponent(Usable)
            if usable then
                local use = Use(level, entity, ability, target_coord)
                entity:getComponent(Control):setAction(use)
            end
        end

        if Gamestate.current() == self then Gamestate.pop() end
    end

    -- ability can be a class ability, item (wand), spell ...
    local enter = function(self, from, ability_)
        assert(getmetatable(from) == Game, 'invalid argument for "from", expected: "Game"')

        game, ability = from, ability_

        entity:getComponent(Control):setEnabled(false)
        game:setActionsEnabled(false)
    end

    local leave = function(self, to)
        entity:getComponent(Control):setEnabled(true)
        game:setActionsEnabled(true)

        game, ability = nil, nil
    end

    local keyReleased = function(self, key, scancode)        
        if Gamestate.current() == self and key == 'escape' then
            Gamestate.pop()
        end
    end

    return setmetatable({
        -- methods
        draw            = draw,
        enter           = enter,
        leave           = leave,
        update          = update,
        setFrame        = setFrame,
        keyReleased     = keyReleased,
        mouseReleased   = mouseReleased,
    }, SelectTarget)
end

return setmetatable(SelectTarget, {
    __call = function(_, ...) return SelectTarget.new(...) end,
})
