-- Math Helper Module
-- Common Math functions
-- @usage local Math = require('util/Math')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

Math = {}

-- Rounding function
-- Example Math.round(11.11111, 1) = 11.1
-- @param number - decimal number to round
-- @param precision - amount of decimal point to round to
function Math.round(number, precision)
    return math.floor(number * math.pow(10, precision) + 0.5) / math.pow(10, precision)
end

return Math
