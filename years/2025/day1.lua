return function(path)
  local lines = readLines(path)
  local dial = 50

  local function step(d, dir, clicks)
    if dir == 'R' then
      return (d + clicks) % 100
    end
    return (d - clicks) % 100
  end

  local part1 = 0
  for i = 1, #lines do
    local line = lines[i]
    local dir = string.sub(line, 1, 1)
    local clicks = tonumber(string.sub(line, 2))
    dial = step(dial, dir, clicks)
    if dial == 0 then
      part1 = part1 + 1
    end
  end

  dial = 50
  local part2 = 0
  for i = 1, #lines do
    local line = lines[i]
    local dir = string.sub(line, 1, 1)
    local clicks = tonumber(string.sub(line, 2))
    local delta = dir == 'R' and 1 or -1
    for _ = 1, clicks do
      dial = (dial + delta) % 100
      if dial == 0 then
        part2 = part2 + 1
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
