-- Time Helper Module
-- Common Time functions
-- @usage local Time = require('util/Time')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

Time = {}

-- Returns hours converted from game ticks
-- @param t - Factorio game tick
function Time.tick_to_day(t)
    return Time.tick_to_hour(t) / 24
end

-- Returns hours converted from game ticks
-- @param t - Factorio game tick
function Time.tick_to_hour(t)
    return Time.tick_to_sec(t) / 3600
end

-- Returns minutes converted from game ticks
-- @param t - Factorio game tick
function Time.tick_to_min(t)
    return Time.tick_to_sec(t) / 60
end

-- Returns seconds converted from game ticks
-- @param t - Factorio game tick
function Time.tick_to_sec(t)
    -- return game.speed * (t / 60)
    return (t / 60)
end

-- Returns a time string in h:m:s format
-- @param t - Factorio game tick
-- @return hms object
function Time.tick_to_time_hms(t)
    local total_sec = Time.tick_to_sec(t)
    return {
        h = math.floor(total_sec / 3600),
        m = math.floor(total_sec % 3600 / 60),
        s = math.floor(total_sec % 60)
    }
end

-- Returns a time object representing time passed in game
-- @return hms object
function Time.game_time_pased()
    return Time.tick_to_time_hms(game.tick)
end

return Time
