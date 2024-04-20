local M = {}

M.fixGamestatePushPop = function()
    local gs_push = Gamestate.push
    Gamestate.push = function(...)
        gs_push(...)
        -- prevent a single black frame from being shown, by immediately forcing an update
        Gamestate.update(0)
    end        

    local gs_pop = Gamestate.pop
    Gamestate.pop = function(...) 
        gs_pop(...)
        -- prevent a single black frame from being shown, by immediately forcing an update
        Gamestate.update(0)
    end
end

return M
