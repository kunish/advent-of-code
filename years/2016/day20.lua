local MAX = 4294967295

return function(path)
  local lines = readLines(path)
  local ranges = {}
  for _, line in ipairs(lines) do
    local a, b = line:match('(%d+)%-(%d+)')
    if a then
      ranges[#ranges + 1] = { tonumber(a), tonumber(b) }
    end
  end

  table.sort(ranges, function(x, y)
    return x[1] < y[1]
  end)

  local merged = {}
  for _, r in ipairs(ranges) do
    local lo, hi = r[1], r[2]
    if #merged == 0 or lo > merged[#merged][2] + 1 then
      merged[#merged + 1] = { lo, hi }
    else
      merged[#merged][2] = math.max(merged[#merged][2], hi)
    end
  end

  local part1
  if merged[1][1] > 0 then
    part1 = 0
  else
    for i = 1, #merged - 1 do
      local gap_start = merged[i][2] + 1
      local gap_end = merged[i + 1][1] - 1
      if gap_start <= gap_end then
        part1 = gap_start
        break
      end
    end
  end

  local allowed = 0
  local cursor = 0
  for _, r in ipairs(merged) do
    local lo, hi = r[1], r[2]
    if lo > cursor then
      allowed = allowed + (lo - cursor)
    end
    if hi + 1 > cursor then
      cursor = hi + 1
    end
  end
  if cursor <= MAX then
    allowed = allowed + (MAX - cursor + 1)
  end

  print('Part 1: ' .. tostring(part1))
  print('Part 2: ' .. tostring(allowed))
end
