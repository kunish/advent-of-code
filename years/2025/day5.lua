return function(path)
  local lines = readLines(path)
  local blank
  for i = 1, #lines do
    if lines[i] == '' then
      blank = i
      break
    end
  end

  local ranges = {}
  for i = 1, blank - 1 do
    local line = lines[i]
    local dash = line:find('-', 1, true)
    local lo = tonumber(line:sub(1, dash - 1))
    local hi = tonumber(line:sub(dash + 1))
    ranges[#ranges + 1] = { lo = lo, hi = hi }
  end

  local ids = {}
  for i = blank + 1, #lines do
    if lines[i] ~= '' then
      ids[#ids + 1] = tonumber(lines[i])
    end
  end

  local function in_any_range(x)
    for j = 1, #ranges do
      local rr = ranges[j]
      if x >= rr.lo and x <= rr.hi then
        return true
      end
    end
    return false
  end

  local part1 = 0
  for i = 1, #ids do
    if in_any_range(ids[i]) then
      part1 = part1 + 1
    end
  end

  table.sort(ranges, function(a, b)
    return a.lo < b.lo
  end)

  local merged = {}
  for i = 1, #ranges do
    local right = ranges[i]
    if #merged == 0 or right.lo > merged[#merged].hi + 1 then
      merged[#merged + 1] = { lo = right.lo, hi = right.hi }
    else
      local left = merged[#merged]
      merged[#merged] = {
        lo = left.lo < right.lo and left.lo or right.lo,
        hi = left.hi > right.hi and left.hi or right.hi,
      }
    end
  end

  local part2 = 0
  for i = 1, #merged do
    part2 = part2 + (merged[i].hi - merged[i].lo + 1)
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
