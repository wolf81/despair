local EncounterBuilder = {}
  EncounterBuilder.new = function(level)
    
    return setmetatable({    
    },EncounterBuilder)
end

return setmetatable(  EncounterBuilder, {
    __call = function(_, ...) return  EncounterBuilder.new(...) end,
})
