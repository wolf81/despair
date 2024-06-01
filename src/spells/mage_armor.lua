--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local MageArmor = {}

local function getLevel(entity)
    local component = entity:getComponent(Class) or entity:getComponent(NPC)
    return component:getLevel()
end

local function getIcon(quad_idx)
    local texture = TextureCache:get('uf_interface')
    local quads = QuadCache:get('uf_interface')
    local quad = quads[quad_idx]

    local quad_w, quad_h = select(3, quad:getViewport())

    local canvas = love.graphics.newCanvas(quad_h, quad_h)
    canvas:renderTo(function() 
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.draw(texture, quad, 0, 0)
    end)

    return canvas
end

MageArmor.new = function(level, entity, coord)
    local cast = function(self, duration)
        print('cast mage armor')

        -- duration: 1 hour (3600 seconds) per level
        local exp_time = level:getScheduler():getTime() + getLevel(entity) * 3600

        local modify_ac = Modify('mage_armor', 'ac', 4, exp_time)

        -- configure icon
        modify_ac:setIcon(getIcon(400))

        local conditions = entity:getComponent(Conditions)
        conditions:add(modify_ac)
    end

    return setmetatable({
        -- methods
        cast = cast,
    }, MageArmor)
end

return setmetatable(MageArmor, {
    __call = function(_, ...) return MageArmor.new(...) end,
})
