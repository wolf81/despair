--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local mfloor = math.floor

local EnterName = {}

local function generateTextButtonTexture(title)
    return TextureGenerator.generateTextButtonTexture(80, 32, title)
end

EnterName.new = function(name, fn)
    local background = TextureGenerator.generatePanelTexture(220, 100)
    local background_w, background_h = background:getDimensions()
    local background_x = mfloor((WINDOW_W - background_w) / 2)
    local background_y = mfloor((WINDOW_H - background_h) / 2)

    local textfield = UI.makeTextfield(name)

    local frame = Rect(background_x, background_y, background_w, background_h)

	local from_scene, overlay = nil, Overlay()

	local dismiss = function() overlay:fadeOut(Gamestate.pop) end

    local confirm = function() 
        if fn then fn(textfield.widget:getText()) end
        dismiss()
    end

    local confirm_button = UI.makeButton(confirm, generateTextButtonTexture('OK'))

    local layout = tidy.Border(tidy.Margin(10), {
        tidy.VStack(tidy.Spacing(10), tidy.Stretch(1), {
            UI.makeLabel('ENTER NAME', { 1.0, 1.0, 1.0, 1.0 }, 'center', 'start'),
        	textfield,
            tidy.HStack({
                UI.makeButton(dismiss, generateTextButtonTexture('Cancel')),
                UI.makeFlexSpace(),
                confirm_button,
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

        confirm_button.widget:setEnabled(#textfield.widget:getText() > 0)
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

        textfield.widget:keyReleased(key, scancode)
    end

    local textInput = function(self, text) textfield.widget:textInput(text) end

    local setName = function(self, name) textfield.widget:setText(name) end

    local getName = function(self) return textfield.widget:getText() end

	return setmetatable({
		-- methods
		draw 		= draw,
		enter 		= enter,
		leave 		= leave,
		update 		= update,
        setName     = setName,
        getName     = getName,
		setFrame 	= setFrame,
		getFrame 	= getFrame,
		textInput	= textInput,
		keyReleased = keyReleased,
	}, EnterName)
end

return setmetatable(EnterName, {
	__call = function(_, ...) return EnterName.new(...) end,
})
