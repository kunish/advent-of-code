local M = {}

local function escape_pattern(s)
  return (s:gsub('([%(%)%.%%%+%-%*%?%[%]%^%$])', '%%%1'))
end

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
  assert(delimiter ~= '', 'delimiter must not be empty')

  local result = {}
  local escaped_delimiter = escape_pattern(delimiter)
  for match in (s .. delimiter):gmatch('(.-)' .. escaped_delimiter) do
    table.insert(result, match)
  end

  return result
end

return M
