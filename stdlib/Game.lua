--- The game module.
-- @module Game
-- @usage local Game = require('stdlib/Game')

Game = {}

--- Print msg if specified var evaluates to false.
-- @tparam Mixed var variable to evaluate
-- @tparam[opt="missing value"] string msg message
function Game.fail_if_missing(var, msg)
    if not var then
        error(msg .. var or "Missing value", 3)
    end
    return false
end

return Game
