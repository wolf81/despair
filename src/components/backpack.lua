--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Backpack = {}

local MAX_BACKPACK_SIZE = 30

function Backpack.new(entity, def)
    local items = {}

    -- insert an item into backpack
    local put = function(self, item)
        if item == nil then return end

        if #items >= MAX_BACKPACK_SIZE then return false end

        Signal.emit('put', item)

        table.insert(items, item)

        return true
    end

    -- remove an item from backpack, either by id or using a filter function
    local take = function(self, arg)
        assert(arg ~= nil, 'missing argument: "number" or "function"')

        local arg_type = type(arg)

        if arg_type == 'function' then
            local removed = {}

            for idx, item in ipairs(items) do
                if arg(item) then
                    table.insert(removed, table.remove(items, idx))
                end
            end

            return removed
        elseif arg_type == 'number' then
            assert(arg > 0 and arg <= MAX_BACKPACK_SIZE, 
                'index ' .. arg .. ' out of bounds, should be between 1 and ' .. MAX_BACKPACK_SIZE)

            return table.remove(items, arg)
        end

        error('invalid argument type "' .. arg_type .. '"')
    end

    local peek = function(self, idx) return items[idx] end

    local getSize = function(self) return #items, MAX_BACKPACK_SIZE end

    local isFull = function(self) return #items == MAX_BACKPACK_SIZE end

    local takeLast = function(self)
        if #items > 0 then
            return table.remove(items, #items)
        end
    end

    local dropItem = function(self, item, level)
        if not item then return end

        item.coord = entity.coord:clone()
        level:addEntity(item)
    end

    local equipAll = function(self)
        for idx = #items, 1, -1 do
            local item = items[idx]
            local equippable = item:getComponent(Equippable)
            if equippable and equippable:equip(entity) then
                self:take(idx)
            end
        end
    end

    -- add all items to backpack
    for _, id in ipairs(def['equip']) do
        put(nil, EntityFactory.create(id))
    end

    return setmetatable({
        -- methods
        put         = put,
        peek        = peek,
        take        = take,
        isFull      = isFull,
        getSize     = getSize,
        takeLast    = takeLast,
        dropItem    = dropItem,
        equipAll    = equipAll,
    }, Backpack)
end

return setmetatable(Backpack, {
    __call = function(_, ...) return Backpack.new(...) end,
})
