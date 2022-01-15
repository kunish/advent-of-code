local M = {}

---@param file string
M.read_lines_from = function(file)
  local lines = {}

  for line in io.lines(file) do
    if line ~= '' then
      lines[#lines + 1] = string.gsub(line, '^%s*(.-)%s*$', '%1')
    end
  end

  return lines
end

---@param s string
---@param delimiter string
M.split_string = function(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
    table.insert(result, match)
  end

  return result
end

return M
