local function day17(path)
  local lines = readLines(path)
  local clay = {}
  local function set(x, y)
    clay[x * 65536 + y] = true
  end
  local function has(x, y)
    return clay[x * 65536 + y]
  end

  local miny, maxy = math.huge, -math.huge
  local minx, maxx = math.huge, -math.huge

  for _, ln in ipairs(lines) do
    local a, b, c = ln:match('x=(%d+), y=(%d+)%.%.(%d+)')
    if a then
      local x = tonumber(a)
      local y1 = tonumber(b)
      local y2 = tonumber(c)
      if y1 > y2 then
        y1, y2 = y2, y1
      end
      for y = y1, y2 do
        set(x, y)
        miny = math.min(miny, y)
        maxy = math.max(maxy, y)
        minx = math.min(minx, x)
        maxx = math.max(maxx, x)
      end
    else
      local y, x1, x2 = ln:match('y=(%d+), x=(%d+)%.%.(%d+)')
      if y then
        y = tonumber(y)
        x1 = tonumber(x1)
        x2 = tonumber(x2)
        if x1 > x2 then
          x1, x2 = x2, x1
        end
        for x = x1, x2 do
          set(x, y)
          miny = math.min(miny, y)
          maxy = math.max(maxy, y)
          minx = math.min(minx, x)
          maxx = math.max(maxx, x)
        end
      end
    end
  end

  local flowing = {}
  local settled = {}
  local memo = {}

  local function fkey(x, y)
    return x * 65536 + y
  end

  -- Returns '~' if this cell becomes settled water, '|' if flowing (or drains)
  local function fill(x, y)
    if y > maxy then
      return '|'
    end
    if has(x, y) then
      return '#'
    end
    local k = fkey(x, y)
    local m = memo[k]
    if m then
      return m
    end

    local below = fill(x, y + 1)
    if below == '|' then
      if y >= miny then
        flowing[k] = true
      end
      memo[k] = '|'
      return '|'
    end

    local xl, xr = x, x
    while not has(xl - 1, y) do
      local bl = fill(xl - 1, y + 1)
      if bl == '|' then
        break
      end
      xl = xl - 1
    end
    while not has(xr + 1, y) do
      local br = fill(xr + 1, y + 1)
      if br == '|' then
        break
      end
      xr = xr + 1
    end

    local wall_l = has(xl - 1, y)
    local wall_r = has(xr + 1, y)

    if wall_l and wall_r then
      for xx = xl, xr do
        local fk = fkey(xx, y)
        settled[fk] = true
        memo[fk] = '~'
      end
      memo[k] = '~'
      return '~'
    end

    for xx = xl, xr do
      local fk = fkey(xx, y)
      if y >= miny then
        flowing[fk] = true
      end
      memo[fk] = '|'
    end
    if not wall_l then
      fill(xl - 1, y)
    end
    if not wall_r then
      fill(xr + 1, y)
    end
    memo[k] = '|'
    return '|'
  end

  minx = math.min(minx, 500) - 1
  maxx = math.max(maxx, 500) + 1

  fill(500, 0)

  local part1 = 0
  local part2 = 0
  for y = miny, maxy do
    for x = minx, maxx do
      local fk = fkey(x, y)
      if settled[fk] then
        part1 = part1 + 1
        part2 = part2 + 1
      elseif flowing[fk] then
        part1 = part1 + 1
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day17(path)
end
