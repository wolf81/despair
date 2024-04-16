local ActionBar = {}

ActionBar.new = function(width, ...)
    local actions = {...}

    local layout =
    
    return setmetatable({
    }, ActionBar)
end

return setmetatable(ActionBar, {
    __call = function(_, ...) return ActionBar.new(...) end,
})
