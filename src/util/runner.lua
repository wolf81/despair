--  Dungeon of Despair
--
--  Author: Wolfgang Schreurs
--  info+despair@wolftrail.net

local Runner = {}

Runner.new = function(loading, completion)
    -- wrap the loading function inside a coroutine
    -- yield the results of the call to the loading function back to coroutine.resume() 
    local loader = coroutine.create(function() 
        local args = { loading() }
        coroutine.yield(unpack(args))
    end)

    local update = function(self)
        local status = coroutine.status(loader)
        local did_finish = status ~= 'running'
        local args = {}

        -- in suspended state, get results from coroutine.yield() skipping boolean status value
        if status == 'suspended' then
            args = { select(2, coroutine.resume(loader)) }
        end

        -- call completion handler if defined and coroutine is finished
        -- afterwards set completion handler to nil, to prevent repeated calls
        if did_finish and completion then
            completion(unpack(args))
            completion = nil
        end

        return not did_resume
    end

    return setmetatable({
        update      = update,        
    }, Runner)
end

return setmetatable(Runner, {
    __call = function(_, ...) return Runner.new(...) end,
})
