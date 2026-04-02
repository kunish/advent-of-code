local function is_trap(left, center, right)
  return (left and center and not right)
    or (not left and center and right)
    or (left and not center and not right)
    or (not left and not center and right)
end

local function next_row(prev)
  local n = #prev
  local out = {}
  for i = 1, n do
    local L = i > 1 and prev:sub(i - 1, i - 1) == '^'
    local C = prev:sub(i, i) == '^'
    local R = i < n and prev:sub(i + 1, i + 1) == '^'
    out[i] = is_trap(L, C, R) and '^' or '.'
  end
  return table.concat(out)
end

local function count_safe(row_str)
  local n = 0
  for i = 1, #row_str do
    if row_str:sub(i, i) == '.' then
      n = n + 1
    end
  end
  return n
end

local function solve(rows, first_line)
  local row = first_line
  local total = count_safe(row)
  for _ = 2, rows do
    row = next_row(row)
    total = total + count_safe(row)
  end
  return total
end

return function(path)
  local lines = readLines(path)
  local first = lines[1]:gsub('%s+', '')

  print('Part 1: ' .. tostring(solve(40, first)))
  print('Part 2: ' .. tostring(solve(400000, first)))
end
