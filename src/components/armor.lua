local Armor = {}

Armor.new = function(entity, def)
    local base = def['ac'] or 0

    local getValue = function(self)
        -- TODO: add values from equipment
        return base
    end

    return setmetatable({
        -- properties
        base        = base,
        -- methods
        getValue    = getValue,
    }, Armor)
end

return setmetatable(Armor, {
    __call = function(_, ...) return Armor.new(...) end,
})
