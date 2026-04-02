local function day22(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = 0
  for _, ln in ipairs(lines) do
    if #ln > cols then
      cols = #ln
    end
  end

  local infected = {}
  for r = 1, rows do
    local ln = lines[r]
    for c = 1, #ln do
      if ln:sub(c, c) == '#' then
        infected[r .. ',' .. c] = true
      end
    end
  end

  local cr = math.floor(rows / 2) + 1
  local cc = math.floor(cols / 2) + 1
  local dr, dc = -1, 0

  local function turn_left()
    dr, dc = -dc, dr
  end

  local function turn_right()
    dr, dc = dc, -dr
  end

  local function reverse_dir()
    dr, dc = -dr, -dc
  end

  local count1 = 0
  for _ = 1, 10000 do
    local k = cr .. ',' .. cc
    if infected[k] then
      turn_right()
      infected[k] = nil
    else
      turn_left()
      infected[k] = true
      count1 = count1 + 1
    end
    cr = cr + dr
    cc = cc + dc
  end

  local state = {}
  for r = 1, rows do
    local ln = lines[r]
    for c = 1, #ln do
      if ln:sub(c, c) == '#' then
        state[r .. ',' .. c] = 2
      end
    end
  end

  cr = math.floor(rows / 2) + 1
  cc = math.floor(cols / 2) + 1
  dr, dc = -1, 0
  local count2 = 0

  for _ = 1, 10000000 do
    local k = cr .. ',' .. cc
    local s = state[k] or 0
    if s == 0 then
      turn_left()
      state[k] = 1
    elseif s == 1 then
      state[k] = 2
      count2 = count2 + 1
    elseif s == 2 then
      turn_right()
      state[k] = 3
    else
      reverse_dir()
      state[k] = 0
    end
    cr = cr + dr
    cc = cc + dc
  end

  print(string.format('Part 1: %d', count1))
  print(string.format('Part 2: %d', count2))
end

return function(path)
  return day22(path)
end
