local function parse_row_col(lines)
  local text = table.concat(lines, ' ')
  local row = tonumber(text:match('row%s+(%d+)'))
  local col = tonumber(text:match('column%s+(%d+)'))
  return row, col
end

local function code_at(row, col)
  local s = row + col
  local before = (s - 2) * (s - 1) // 2
  local steps = before + (col - 1)
  local v = 20151125
  for _ = 1, steps do
    v = (v * 252533) % 33554393
  end
  return v
end

local function day25(path)
  local lines = readLines(path)
  local row, col = parse_row_col(lines)
  print(string.format('Part 1: %d', code_at(row, col)))
  print('Part 2: Merry Christmas!')
end

return function(path)
  return day25(path)
end
