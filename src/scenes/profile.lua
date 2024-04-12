local Profile = {}

Profile.new = function()
    return setmetatable({
    }, Profile)
end

return setmetatable(Profile, {
    __call = function(_, ...) return Profile.new(...) end,
})
