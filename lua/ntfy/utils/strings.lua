M = {}

-- Returns true if string is empty
M.is_empty = function(s) return s == nil or s == '' end

-- Returns a table from a CSV string
M.csv_to_table = function(s)
  local sep = ","
  local parsed_values = {}
  for value in string.gmatch(s, "([^"..sep.."]+)") do
    table.insert(parsed_values, value)
  end
  return parsed_values
end

M.table_to_csv = function(t)
  local csv_str = ""
  for _, topic in ipairs(t) do
    csv_str = csv_str .. "," .. topic
  end
  csv_str = csv_str:sub(2)
  return csv_str
end

return M
