local function parse_nums(line)
  local t = {}
  for n in line:gmatch('%d+') do
    t[#t + 1] = tonumber(n)
  end
  return t
end

local function ways_to_win(time, record)
  local n = 0
  for hold = 0, time do
    if (time - hold) * hold > record then
      n = n + 1
    end
  end
  return n
end

local function day6(path)
  local lines = readLines(path)
  local times = parse_nums(lines[1]:gsub('^Time:%s*', ''))
  local dists = parse_nums(lines[2]:gsub('^Distance:%s*', ''))
  local part1 = 1
  for i = 1, #times do
    part1 = part1 * ways_to_win(times[i], dists[i])
  end
  local t2 = tonumber(((lines[1]:gsub('^Time:%s*', '')):gsub('%s', '')))
  local d2 = tonumber(((lines[2]:gsub('^Distance:%s*', '')):gsub('%s', '')))
  local part2 = ways_to_win(t2, d2)
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day6(p)
end
