-- Additional functions for lua tables
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --


Table = {}


-- Returns the table index that the element resides in,
-- Returns -1 if the element is not in the table
-- @param table - lua table (array)
-- @element - element in the table
function Table.el_idx(table, element)
  for i, value in pairs(table) do
    if value == element then
      return i
    end
  end
  return -1
end


-- Returns true if element is in table, false otherwise
-- @param table - lua table (array)
-- @element - element in the table
function Table.contains(table, element)
  if Table.el_idx(table, element) ~= -1 then
    return true
  end
  return false
end


return Table
