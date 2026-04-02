local function day1(path)
  local lines = readLines(path)
  local s = (lines[1] or ''):gsub('%s', '')
  local n = #s
  local part1 = 0
  for i = 1, n do
    local a = s:sub(i, i)
    local b = s:sub(i % n + 1, i % n + 1)
    if a == b then
      part1 = part1 + tonumber(a)
    end
  end

  local half = n // 2
  local part2 = 0
  for i = 1, n do
    local a = s:sub(i, i)
    local j = ((i - 1 + half) % n) + 1
    local b = s:sub(j, j)
    if a == b then
      part2 = part2 + tonumber(a)
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day1(path)
end
