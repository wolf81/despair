local Weapon = {}

Weapon.new = function(entity, def)
    local getAttack = function(self)
        -- TODO: use equipped weapon
        return math.random(1, 20)
    end

    local getDamage = function(self)
        -- TODO: use equipped weapon
        return math.random(15, 25)
    end

    return setmetatable({
        -- methods
        getAttack   = getAttack,
        getDamage   = getDamage,
    }, Weapon)
end

return setmetatable(Weapon, {
    __call = function(_, ...) return Weapon.new(...) end,
})
