return function(path)
  local lines = readLines(path)
  local depart = tonumber(lines[1])
  local bus_line = lines[2] or ''

  local best_wait = math.huge
  local best_id = 0
  for token in bus_line:gmatch('[^,]+') do
    if token ~= 'x' then
      local id = tonumber(token)
      if id then
        local w = id - (depart % id)
        if w == id then
          w = 0
        end
        if w < best_wait then
          best_wait = w
          best_id = id
        end
      end
    end
  end
  local part1 = best_wait * best_id

  local congruences = {}
  local idx = 0
  for token in bus_line:gmatch('[^,]+') do
    if token ~= 'x' then
      local id = tonumber(token)
      if id then
        local a = (-idx) % id
        if a < 0 then
          a = a + id
        end
        congruences[#congruences + 1] = { a, id }
      end
    end
    idx = idx + 1
  end

  local t = 0
  local step = 1
  local c = 1
  while c <= #congruences do
    local a, m = congruences[c][1], congruences[c][2]
    while t % m ~= a do
      t = t + step
    end
    step = step * m
    c = c + 1
  end
  local part2 = t

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
