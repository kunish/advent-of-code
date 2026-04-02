return function(path)
  local lines = readLines(path)
  local left, right = {}, {}
  local n = 0
  for _, line in ipairs(lines) do
    local a, b = line:match('^(%d+)%s+(%d+)$')
    if a then
      n = n + 1
      left[n] = tonumber(a)
      right[n] = tonumber(b)
    end
  end
  table.sort(left)
  table.sort(right)
  local part1 = 0
  for i = 1, n do
    local d = left[i] - right[i]
    if d < 0 then
      d = -d
    end
    part1 = part1 + d
  end
  local count = {}
  for i = 1, n do
    local v = right[i]
    count[v] = (count[v] or 0) + 1
  end
  local part2 = 0
  for i = 1, n do
    local v = left[i]
    part2 = part2 + v * (count[v] or 0)
  end
  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
