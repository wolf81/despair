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
    local ox, oy = 0, 0

    local coord = nil

    local update = function(self, dt)
        game:update(dt)

        local mx, my = love.mouse.getPosition()
        local pos = vector(mx, my)

        local level = game:getDungeon():getLevel()
        local pos_x, pos_y = level:toWorldPos(mx + TILE_SIZE, my)
        local level_x, level_y = mfloor(pos_x / TILE_SIZE + 0.5), mfloor(pos_y / TILE_SIZE + 0.5)
        local level_coord = vector(level_x, level_y)

        if level:inLineOfSight(entity.coord, level_coord) then
            -- TODO: also check if coord is covered by fog of war? 
            -- FIXME: maybe fog of war calculation is wrong; it doesn't always match line of sight
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
        if button == 2 then Gamestate.pop() end
        -- print('mouseReleased', mx, my, button)
    end

    -- ability can be a class ability, item (wand), spell ...
    local enter = function(self, from, ability)
        assert(getmetatable(from) == Game, 'invalid argument for "from", expected: "Game"')

        game, ability = from, ability

        entity:getComponent(Control):setEnabled(false)
        game:setActionsEnabled(false)
    end

    local leave = function(self, to)
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
