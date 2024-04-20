--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local M = {}

M.makeButton = function(action, image)
    if not image then
        return tidy.Elem(ActionButton(action), tidy.MinSize(48), tidy.Stretch(0))
    else
        return tidy.Elem(ImageButton(image, action), tidy.MinSize(50), tidy.Stretch(0))
    end
end

M.makeFlexPanel = function()
    return tidy.Elem(FlexPanel(), tidy.MinSize(0, 48), tidy.Stretch(1, 0))
end

M.makeView = function(view, ...)
    return tidy.Elem(view, ...)
end

M.makeLabel = function(text, color)
    local label = Label(text, color or { 1.0, 1.0, 1.0, 1.0 })
    local w, h = label:getSize()
    return tidy.Elem(label, tidy.MinSize(w, h), tidy.Stretch(1, 0))
end

M.makeResourceBar = function(entity, type)
    local resource_bar = ResourceBar(entity, type)
    local w, h = resource_bar:getSize()
    return tidy.Elem(resource_bar, tidy.MinSize(w, h), tidy.Stretch(1, 0))
end

M.makeChart = function(cartographer)
    -- local chart = cartographer:getChart()
    local w, h = cartographer:getSize()
    return tidy.Elem(cartographer, tidy.MinSize(w, h), tidy.Stretch(1, 0))
end

M.makeFlexSpace = function()
    return tidy.Elem(FlexSpace(), tidy.Stretch(1))
end

M.makeFixedSpace = function(w, h)
    local stretch_x = (w == 0) and 1 or 0
    local stretch_y = (h == 0) and 1 or 0
    return tidy.Elem(FlexSpace(), tidy.MinSize(w, h), tidy.Stretch(stretch_x, stretch_y))
end

return M
