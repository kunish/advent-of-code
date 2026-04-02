local function count_char(s, ch)
  local c = 0
  local j = 1
  while j <= #s do
    if s:sub(j, j) == ch then
      c = c + 1
    end
    j = j + 1
  end
  return c
end

return function(path)
  local lines = readLines(path)
  local part1, part2 = 0, 0
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local lo, hi, ch, pwd = line:match('^(%d+)%-(%d+) ([^:]+): (%S+)$')
      lo = tonumber(lo)
      hi = tonumber(hi)
      local cnt = count_char(pwd, ch)
      if cnt >= lo and cnt <= hi then
        part1 = part1 + 1
      end
      local at_lo = pwd:sub(lo, lo) == ch
      local at_hi = pwd:sub(hi, hi) == ch
      if at_lo ~= at_hi then
        part2 = part2 + 1
      end
    end
    i = i + 1
  end
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
