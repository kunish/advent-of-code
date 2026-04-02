local function seat_id(s)
  local v = 0
  local j = 1
  while j <= #s do
    local bit = s:sub(j, j)
    v = v * 2
    if bit == 'B' or bit == 'R' then
      v = v + 1
    end
    j = j + 1
  end
  return v
end

return function(path)
  local lines = readLines(path)
  local max_id = 0
  local present = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local id = seat_id(line)
      if id > max_id then
        max_id = id
      end
      present[id] = true
    end
    i = i + 1
  end

  local part2 = 0
  local k = 1
  while k < 1023 do
    if not present[k] and present[k - 1] and present[k + 1] then
      part2 = k
      break
    end
    k = k + 1
  end

  print(string.format('Part 1: %d', max_id))
  print(string.format('Part 2: %d', part2))
end
