return function(path)
  local lines = readLines(path)
  local elves = {}

  local function key(x, y)
    return x .. ',' .. y
  end

  for r = 1, #lines do
    local line = lines[r]
    for c = 1, #line do
      if line:sub(c, c) == '#' then
        elves[key(c - 1, r - 1)] = true
      end
    end
  end

  local checks = {
    { { 0, -1 }, { -1, -1 }, { 1, -1 } },
    { { 0, 1 }, { -1, 1 }, { 1, 1 } },
    { { -1, 0 }, { -1, -1 }, { -1, 1 } },
    { { 1, 0 }, { 1, -1 }, { 1, 1 } },
  }

  local function has_neighbor(ex, ey, elset)
    for dy = -1, 1 do
      for dx = -1, 1 do
        if dx ~= 0 or dy ~= 0 then
          if elset[key(ex + dx, ey + dy)] then
            return true
          end
        end
      end
    end
    return false
  end

  local function round(start_dir, elset)
    local proposals = {}
    local prop_target = {}
    for k, _ in pairs(elset) do
      local x, y = k:match('^(-?%d+),(-?%d+)$')
      x, y = tonumber(x), tonumber(y)
      if not has_neighbor(x, y, elset) then
        goto skip
      end
      for s = 0, 3 do
        local di = ((start_dir + s - 1) % 4) + 1
        local blocked = false
        for t = 1, 3 do
          local dx, dy = checks[di][t][1], checks[di][t][2]
          if elset[key(x + dx, y + dy)] then
            blocked = true
            break
          end
        end
        if not blocked then
          local dx, dy = checks[di][1][1], checks[di][1][2]
          local tx, ty = x + dx, y + dy
          local tk = key(tx, ty)
          proposals[k] = tk
          prop_target[tk] = (prop_target[tk] or 0) + 1
          break
        end
      end
      ::skip::
    end

    local new_elves = {}
    local moved = false
    for k, _ in pairs(elset) do
      local dest = proposals[k]
      if dest and prop_target[dest] == 1 then
        new_elves[dest] = true
        if dest ~= k then
          moved = true
        end
      else
        new_elves[k] = true
      end
    end
    return new_elves, moved
  end

  local e = {}
  for k, v in pairs(elves) do
    e[k] = v
  end

  local start_dir = 1
  for rnd = 1, 10 do
    e, _ = round(start_dir, e)
    start_dir = (start_dir % 4) + 1
  end

  local minx, maxx = 1e9, -1e9
  local miny, maxy = 1e9, -1e9
  for k, _ in pairs(e) do
    local x, y = k:match('^(-?%d+),(-?%d+)$')
    x, y = tonumber(x), tonumber(y)
    if x < minx then
      minx = x
    end
    if x > maxx then
      maxx = x
    end
    if y < miny then
      miny = y
    end
    if y > maxy then
      maxy = y
    end
  end

  local area = (maxx - minx + 1) * (maxy - miny + 1)
  local part1 = area - 0
  for _ in pairs(e) do
    part1 = part1 - 1
  end
  print(string.format('Part 1: %d', part1))

  e = {}
  for k, v in pairs(elves) do
    e[k] = v
  end
  start_dir = 1
  local rnd = 0
  while true do
    rnd = rnd + 1
    local moved
    e, moved = round(start_dir, e)
    start_dir = (start_dir % 4) + 1
    if not moved then
      print(string.format('Part 2: %d', rnd))
      return
    end
  end
end
