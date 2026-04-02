local function day4(path)
  local lines = readLines(path)
  local part1 = 0
  local part2 = 0

  for i = 1, #lines do
    local a1, b1, a2, b2 = lines[i]:match('(%d+)%-(%d+),(%d+)%-(%d+)')
    a1 = tonumber(a1)
    b1 = tonumber(b1)
    a2 = tonumber(a2)
    b2 = tonumber(b2)

    if (a1 <= a2 and b1 >= b2) or (a2 <= a1 and b2 >= b1) then
      part1 = part1 + 1
    end

    if not (b1 < a2 or b2 < a1) then
      part2 = part2 + 1
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day4(p)
end
