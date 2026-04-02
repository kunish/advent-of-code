local function decompressed_len_part1(s)
  local total = 0
  local j = 1
  while j <= #s do
    local c = s:sub(j, j)
    if c == '(' then
      local close = s:find(')', j, true)
      local a, b = s:sub(j + 1, close - 1):match('^(%d+)x(%d+)$')
      a, b = tonumber(a), tonumber(b)
      total = total + a * b
      j = close + 1 + a
    else
      total = total + 1
      j = j + 1
    end
  end
  return total
end

local function decompressed_len_part2(s)
  local function go(i, e)
    local total = 0
    local j = i
    while j <= e do
      if s:sub(j, j) == '(' then
        local close = s:find(')', j, true)
        local a, b = s:sub(j + 1, close - 1):match('^(%d+)x(%d+)$')
        a, b = tonumber(a), tonumber(b)
        local seg_start = close + 1
        local seg_end = seg_start + a - 1
        total = total + b * go(seg_start, seg_end)
        j = seg_end + 1
      else
        total = total + 1
        j = j + 1
      end
    end
    return total
  end
  return go(1, #s)
end

local function day9(path)
  local lines = readLines(path)
  local s = (lines[1] or ''):gsub('%s+', '')
  local p1 = decompressed_len_part1(s)
  local p2 = decompressed_len_part2(s)
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day9(path)
end
