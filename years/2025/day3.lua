return function(path)
  local lines = readLines(path)

  local function max_joltage(bank, batteries)
    if batteries == 1 then
      local best = string.sub(bank, 1, 1)
      for i = 2, #bank do
        local c = string.sub(bank, i, i)
        if c > best then
          best = c
        end
      end
      return best
    end
    local last = #bank - (batteries - 1)
    local bestc = string.sub(bank, 1, 1)
    for i = 2, last do
      local c = string.sub(bank, i, i)
      if c > bestc then
        bestc = c
      end
    end
    local idx
    for i = 1, last do
      if string.sub(bank, i, i) == bestc then
        idx = i
        break
      end
    end
    return bestc .. max_joltage(string.sub(bank, idx + 1), batteries - 1)
  end

  local part1, part2 = 0, 0
  for i = 1, #lines do
    local line = lines[i]
    part1 = part1 + tonumber(max_joltage(line, 2))
    part2 = part2 + tonumber(max_joltage(line, 12))
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
