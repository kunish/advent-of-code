local function day1(path)
  local lines = readLines(path)
  local groups = {}
  local cur = 0
  for i = 1, #lines do
    local line = lines[i]
    if line == '' then
      groups[#groups + 1] = cur
      cur = 0
    else
      cur = cur + tonumber(line)
    end
  end
  groups[#groups + 1] = cur

  local max_sum = 0
  for g = 1, #groups do
    if groups[g] > max_sum then
      max_sum = groups[g]
    end
  end

  table.sort(groups)
  local top3 = groups[#groups] + groups[#groups - 1] + groups[#groups - 2]

  print(string.format('Part 1: %d', max_sum))
  print(string.format('Part 2: %d', top3))
end

return function(p)
  return day1(p)
end
