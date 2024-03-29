--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Backpack = {}

function Backpack.new(entity, def)
    local items = {}

    -- add all items to backpack
    for _, id in ipairs(def['equip']) do
        local item = EntityFactory.create(id)
        items[tostring(item.id)] = item
    end

    -- insert an item into backpack
    local put = function(self, item)
        if item == nil then return end
        items[tostring(item.id)] = item
    end

    -- remove an item from backpack, either by id or using a filter function
    local take = function(self, arg)
        assert(arg ~= nil, 'missing argument: "number" or "function"')

        local arg_type = type(arg)

        if arg_type == 'function' then
            local removed = {}

            for id, item in pairs(items) do
                if not arg(item) then goto continue end

                local item = items[id]
                items[id] = nil
                table.insert(removed, item)

                ::continue::
            end

            return removed
        elseif arg_type == 'number' then
            return items[tostring(arg)]
        end

        error('invalid argument type "' .. arg_type .. '"')
    end

    -- iterate through all items in the backpack
    local each = function(self)
        local key, item = nil, nil

        return function()
            key, item = next(items, key)
            return item
        end
    end

    return setmetatable({
        -- methods
        put     = put,
        take    = take,
        each    = each,
    }, Backpack)
end

return setmetatable(Backpack, {
    __call = function(_, ...) return Backpack.new(...) end,
})
