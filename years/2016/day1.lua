local function day1(path)
  local lines = readLines(path)
  local s = (lines[1] or ''):gsub('%s+', '')
  local x, y = 0, 0
  local dx, dy = 0, 1

  local function turn_left()
    dx, dy = -dy, dx
  end
  local function turn_right()
    dx, dy = dy, -dx
  end

  local visited = { ['0,0'] = true }
  local first_twice = nil

  for raw in s:gmatch('[^,]+') do
    local token = (raw:match('^%s*(.-)%s*$') or '')
    local turn, n = token:match('^([LR])(%d+)$')
    if turn and n then
      n = tonumber(n)
      if turn == 'L' then
        turn_left()
      else
        turn_right()
      end
      for _ = 1, n do
        x = x + dx
        y = y + dy
        local key = string.format('%d,%d', x, y)
        if first_twice == nil and visited[key] then
          first_twice = math.abs(x) + math.abs(y)
        end
        visited[key] = true
      end
    end
  end

  local part1 = math.abs(x) + math.abs(y)
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', first_twice or 0))
end

return function(path)
  return day1(path)
end
