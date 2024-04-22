--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Equippable = {}

Equippable.new = function(entity, def)
    local equip = function(self, target)
        assert(target ~= nil, 'missing argument: "target"')

        local equipment = target:getComponent(Equipment)
        assert(equipment ~= nil, 'missing component: "Equipment"')

        -- we might not be able to equip due to e.g. class restrictions,
        -- so let called know if we succeeded to equip the item
        local success = equipment:equip(entity)
        return success
    end

    local getEffect = function(self)
        if not def.effect then return nil end
        
        return EntityFactory.create(def.effect)
    end    

    return setmetatable({
        -- methods
        equip       = equip,
        getEffect   = getEffect,
    }, Equippable)
end

return setmetatable(Equippable, {
    __call = function(_, ...) return Equippable.new(...) end,
})
