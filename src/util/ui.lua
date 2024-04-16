local M = {}

M.makeButton = function(action, image)
    if not image then
        return tidy.Elem(ActionBarButton(action), tidy.MinSize(48), tidy.Stretch(0))
    else
        return tidy.Elem(ImageButton(image, action), tidy.MinSize(50), tidy.Stretch(0))
    end
end

M.makeFlex = function()
    return tidy.Elem(FlexSpace(), tidy.MinSize(0, 48), tidy.Stretch(1, 0))
end

M.makeView = function(view, ...)
    return tidy.Elem(view, ...)
end

return M
