local function parse_nums(s)
  local t = {}
  for w in s:gmatch('%d+') do
    t[#t + 1] = tonumber(w)
  end
  return t
end

local function day4(path)
  local lines = readLines(path)
  local part1 = 0
  local copies = {}
  local nlines = #lines
  for i = 1, nlines do
    copies[i] = 1
  end

  for i = 1, nlines do
    local line = lines[i]
    local win_str, mine_str = line:match(':%s*(.+)|%s*(.+)')
    local win = {}
    for w in win_str:gmatch('%d+') do
      win[tonumber(w)] = true
    end
    local mine = parse_nums(mine_str)
    local match = 0
    for j = 1, #mine do
      if win[mine[j]] then
        match = match + 1
      end
    end
    if match > 0 then
      part1 = part1 + (1 << (match - 1))
    end
    local c = copies[i]
    for k = 1, match do
      local idx = i + k
      if idx <= nlines then
        copies[idx] = copies[idx] + c
      end
    end
  end

  local part2 = 0
  for j = 1, nlines do
    part2 = part2 + copies[j]
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day4(p)
end
