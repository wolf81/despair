--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local EnterName = {}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

EnterName.new = function(gender, race)
    local background = TextureGenerator.generatePanelTexture(220, 140)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local frame = Rect(background_x, background_y, background_w, background_h)

	local from_scene, overlay = nil, Overlay()

	local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), tidy.Stretch(1), {
            UI.makeLabel('ENTER NAME', { 1.0, 1.0, 1.0, 1.0 }, 'center', 'start'),
            tidy.VStack(tidy.Spacing(2), tidy.Stretch(1), { }),
            tidy.HStack({
                UI.makeButton(dismiss, generateTextButtonTexture('Cancel')),
                UI.makeFlexSpace(),
                UI.makeButton(dismiss, generateTextButtonTexture('OK')),
            }),
        })
    }):setFrame(frame:unpack())

	local draw = function(self)
		from_scene:draw()
		overlay:draw()

		local x, y = frame:unpack()

		love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
		love.graphics.draw(background, x, y)

        for e in layout:eachElement() do e.widget:draw() end
	end

	local update = function(self, dt)
        for e in layout:eachElement() do e.widget:update(dt) end
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
            dismiss()
        end
    end

	return setmetatable({
		-- methods
		draw 		= draw,
		enter 		= enter,
		leave 		= leave,
		update 		= update,
		setFrame 	= setFrame,
		getFrame 	= getFrame,
		keyReleased = keyReleased,
	}, EnterName)
end

return setmetatable(EnterName, {
	__call = function(_, ...) return EnterName.new(...) end,
})
