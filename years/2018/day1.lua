local function day1(path)
  local lines = readLines(path)
  local deltas = {}
  for li = 1, #lines do
    local line = lines[li]
    if line ~= '' then
      deltas[#deltas + 1] = tonumber(line)
    end
  end

  local sum = 0
  for di = 1, #deltas do
    sum = sum + deltas[di]
  end
  local part1 = sum

  local seen = { [0] = true }
  local freq = 0
  local part2 = nil
  while not part2 do
    for di = 1, #deltas do
      freq = freq + deltas[di]
      if seen[freq] then
        part2 = freq
        break
      end
      seen[freq] = true
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day1(path)
end
