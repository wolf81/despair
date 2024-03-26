--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local mmax = math.max

local Weapon = {}

Weapon.new = function(entity, def)
    local equipment = entity:getComponent(Equipment)
    assert(equipment ~= nil, 'component missing: "Equipment"')

    local stats = entity:getComponent(Stats)

    -- TODO: it should not be possible to have no weapon equipped, mainly important for players, 
    -- maybe humanoids - to use fist weapons if other weapons are unequipped

    local getAttack = function(self)
        local weapon = equipment:getItem('mainhand')
        if weapon ~= nil then return weapon.attack end
        return 0
    end

    local getDamage = function(self)
        local base, bonus = 0, 0

        -- calculate weapon damage
        local weapon = equipment:getItem('mainhand')
        if weapon ~= nil then 
            base = ndn.dice(weapon.damage).roll()
        end

        -- calculate strength bonus, if applicable
        if stats ~= nil then
            bonus = stats:getBonus('str')
            if weapon.kind == '2h' then
                bonus = bonus * 2
            end
        end

        return mmax(base + bonus, 0)
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
