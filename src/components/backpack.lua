--[[
--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net
--]]

local Backpack = {}

function Backpack.new(entity, def)
    local items, last_item_gid = {}, nil

    -- add all items to backpack
    for _, id in ipairs(def['equip']) do
        local item = EntityFactory.create(id)
        items[tostring(item.gid)] = item
    end

    -- insert an item into backpack
    local put = function(self, item)
        if item == nil then return end

        local item_gid = tostring(item.gid)
        items[item_gid] = item
        last_item_gid = item_gid

        Signal.emit('put', item)
    end

    -- remove an item from backpack, either by id or using a filter function
    local take = function(self, arg)
        assert(arg ~= nil, 'missing argument: "number" or "function"')

        local arg_type = type(arg)

        if arg_type == 'function' then
            local removed = {}

            for gid, item in pairs(items) do
                if not arg(item) then goto continue end

                local item = items[gid]
                items[gid] = nil
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
        local gid, item = nil, nil

        return function()
            gid, item = next(items, gid)
            return item
        end
    end

    local takeLast = function(self)
        local item = nil

        if last_item_gid ~= nil then
            item = items[last_item_gid]
            items[last_item_gid] = nil
            last_item_gid = nil
        end

        return item
    end

    return setmetatable({
        -- methods
        put         = put,
        take        = take,
        takeLast    = takeLast,
        each        = each,
    }, Backpack)
end

return setmetatable(Backpack, {
    __call = function(_, ...) return Backpack.new(...) end,
})
