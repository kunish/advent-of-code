local function day2(path)
  local lines = readLines(path)

  local function them_idx(c)
    return string.byte(c) - string.byte('A') + 1
  end

  local part1 = 0
  local part2 = 0

  for i = 1, #lines do
    local line = lines[i]
    local a, b = line:match('(%a) (%a)')
    local t = them_idx(a)
    local me = string.byte(b) - string.byte('X') + 1

    local diff = (me - t + 3) % 3
    local outcome
    if diff == 0 then
      outcome = 3
    elseif diff == 1 then
      outcome = 6
    else
      outcome = 0
    end
    part1 = part1 + me + outcome

    local t0 = t - 1
    local want0
    if b == 'Y' then
      want0 = t0
    elseif b == 'X' then
      want0 = (t0 - 1) % 3
    else
      want0 = (t0 + 1) % 3
    end
    local me2 = want0 + 1
    local diff2 = (me2 - t + 3) % 3
    local out2
    if diff2 == 0 then
      out2 = 3
    elseif diff2 == 1 then
      out2 = 6
    else
      out2 = 0
    end
    part2 = part2 + me2 + out2
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day2(p)
end
