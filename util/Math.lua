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

-- Function for line generation
-- TODO: Doesn't always do diagonals
-- @see: https://iq.opengenus.org/bresenham-line-drawining-algorithm/
function Math.bresenhamLine(pointStart, pointEnd)
    local locations = {}

    local x1 = pointStart.x
    local y1 = pointStart.y
    local x2 = pointEnd.x
    local y2 = pointEnd.y

    if(x2 < x1) then
        local xTemp = x1
        local yTemp = y1
        x1 = x2
        y1 = y2
        x2 = xTemp
        y2 = yTemp
    end


    if(x2 == x1) then
        if(y2 < y1) then
            local xTemp = x1
            local yTemp = y1
            x1 = x2
            y1 = y2
            x2 = xTemp
            y2 = yTemp
        end
    end


    local dx = x2 - x1
    local dy = y2 - y1

    local x = x1
    local y = y1

    if(dx > dy) then
        table.insert(locations, {x, y})
        local m = 2 * dy - dx

        for i = 1, dx do
            x = x + 1
            if(m < 0) then
                m = m + 2 * dy
            else
                y = y + 1
                m = m + 2*dy - 2*dx
            end
            table.insert(locations, {x, y})
        end
    else
        table.insert(locations, {x, y})
        local m = 2 * dx - dy

        for i = 1, dy do
            y = y + 1
            if(m < 0) then
                m = m + 2 * dx
            else
                x = x + 1
                m = m + 2*dx - 2*dy
            end
            table.insert(locations, {x, y})
        end
    end
    return locations
end



-- Function for line generation
-- function Math.bresenhamLine1(pointStart, pointEnd)
--     local locations = {}

--     local x1 = pointStart.x
--     local y1 = pointStart.y
--     local x2 = pointEnd.x
--     local y2 = pointEnd.y

--     local dx = x2 - x1
--     local dy = y2 - y1

--     local x = x1
--     local y - y1


--     if(x2 < x1) then
--         local xTemp = x1
--         local yTemp = y1
--         x1 = x2
--         y1 = y2
--         x2 = xTemp
--         y2 = yTemp
--     end

--     local m = 2 * (y2 - y1)
--     local err = m - (x2 - x1)

--     local y = y1
--     for x = x1, x2, 1 do
--         -- Add slope to increment angle formed
--         err = err + m
--         -- Slope error reached limit, time to increment y and update slope error.
--         if(err >= 0) then
--             y = y + 1
--             err = err - 2 * (x2 - x1)
--         end
--         table.insert(locations, {x, y})
--     end
--     return locations
-- end

-- function Math.locationsLine(pointStart, pointEnd)
--     game.print("x1, y1, x2, y2")
--     game.print(pointStart)
--     game.print(pointEnd)
--     local locations = {}

--     local x1 = pointStart.x
--     local y1 = pointStart.y
--     local x2 = pointEnd.x
--     local y2 = pointEnd.y

--     game.print(string.format("dx, dy, m, d"))
--     local dx = x2 - x1
--     game.print(string.format("dx: %d", dx))
--     local dy = y2 - y1
--     game.print(string.format("dy: %d", dy))

--     if(dx == 0) do
--         for x = xLow, xHigh, 1 do
--             local y = m * x + b
--             table.insert(locations, {x, y})
--         end
--     else
--         local m = dy / dx
--         game.print(string.format("m: %d", m))
--         local b = y1 - m * x1
--         game.print(string.format("b: %d", b))

--         local xLow = x1
--         local xHigh = x2

--         if(x2 < x1) then
--             xlow = x2
--             xHigh = x1
--         end

--         for x = xLow, xHigh, 1 do
--             local y = m * x + b
--             table.insert(locations, {x, y})
--         end
--     end
--     return locations
-- end


return Math
