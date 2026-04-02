local function day13(path)
  local lines = readLines(path)
  local h = #lines
  local w = 0
  for y = 1, h do
    local line = lines[y]
    if #line > w then
      w = #line
    end
  end

  local track = {}
  for y = 1, h do
    track[y] = {}
    local line = lines[y]
    for x = 1, w do
      local c = line:sub(x, x)
      if c == '' then
        c = ' '
      end
      if c == '^' or c == 'v' then
        track[y][x] = '|'
      elseif c == '<' or c == '>' then
        track[y][x] = '-'
      else
        track[y][x] = c
      end
    end
  end

  local carts = {}
  for y = 1, h do
    local line = lines[y]
    for x = 1, math.min(#line, w) do
      local c = line:sub(x, x)
      local dir = nil
      if c == '^' then
        dir = 0
      elseif c == '>' then
        dir = 1
      elseif c == 'v' then
        dir = 2
      elseif c == '<' then
        dir = 3
      end
      if dir ~= nil then
        carts[#carts + 1] = { x = x, y = y, d = dir, turn = 0, removed = false }
      end
    end
  end

  local dirs = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }

  local function left(d)
    return (d + 3) % 4
  end

  local function right(d)
    return (d + 1) % 4
  end

  local function curve_slash(d)
    if d == 1 then
      return 0
    end
    if d == 3 then
      return 2
    end
    if d == 0 then
      return 1
    end
    if d == 2 then
      return 3
    end
    return d
  end

  local function curve_backslash(d)
    if d == 1 then
      return 2
    end
    if d == 3 then
      return 0
    end
    if d == 0 then
      return 3
    end
    if d == 2 then
      return 1
    end
    return d
  end

  local function sort_carts(cs)
    table.sort(cs, function(a, b)
      if a.y ~= b.y then
        return a.y < b.y
      end
      return a.x < b.x
    end)
  end

  local function tick(cs, stop_on_crash)
    sort_carts(cs)
    local crash = nil
    local occupied = {}
    for i = 1, #cs do
      local c = cs[i]
      if not c.removed then
        local k = c.y * 65536 + c.x
        occupied[k] = c
      end
    end

    for i = 1, #cs do
      local c = cs[i]
      if not c.removed then
        local oldk = c.y * 65536 + c.x
        occupied[oldk] = nil

        local dx, dy = dirs[c.d + 1][1], dirs[c.d + 1][2]
        c.x = c.x + dx
        c.y = c.y + dy
        local cell = track[c.y][c.x]
        if cell == '+' then
          local t = c.turn % 3
          if t == 0 then
            c.d = left(c.d)
          elseif t == 2 then
            c.d = right(c.d)
          end
          c.turn = c.turn + 1
        elseif cell == '/' then
          c.d = curve_slash(c.d)
        elseif cell == '\\' then
          c.d = curve_backslash(c.d)
        end

        local nk = c.y * 65536 + c.x
        if occupied[nk] then
          crash = { x = c.x, y = c.y }
          occupied[nk].removed = true
          c.removed = true
          if stop_on_crash then
            return crash
          end
          occupied[nk] = nil
        else
          occupied[nk] = c
        end
      end
    end
    return crash
  end

  local function clone_carts()
    local t = {}
    for i = 1, #carts do
      local c = carts[i]
      t[i] = { x = c.x, y = c.y, d = c.d, turn = c.turn, removed = false }
    end
    return t
  end

  local cs1 = clone_carts()
  local part1 = nil
  while not part1 do
    local crash = tick(cs1, true)
    if crash then
      part1 = string.format('%d,%d', crash.x - 1, crash.y - 1)
      break
    end
  end

  local cs2 = clone_carts()
  local part2 = nil
  while true do
    tick(cs2, false)
    local alive = 0
    local last = nil
    for i = 1, #cs2 do
      if not cs2[i].removed then
        alive = alive + 1
        last = cs2[i]
      end
    end
    if alive <= 1 then
      part2 = string.format('%d,%d', last.x - 1, last.y - 1)
      break
    end
  end

  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %s', part2))
end

return function(path)
  return day13(path)
end
