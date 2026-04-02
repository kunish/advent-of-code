local function day18(path)
  local lines = readLines(path)
  local h = #lines
  local w = #lines[1]
  local grid = {}
  for y = 1, h do
    grid[y] = {}
    local ln = lines[y]
    for x = 1, w do
      grid[y][x] = ln:sub(x, x)
    end
  end

  local function count_adj(y, x)
    local trees, lumber = 0, 0
    for dy = -1, 1 do
      for dx = -1, 1 do
        if dx ~= 0 or dy ~= 0 then
          local ny, nx = y + dy, x + dx
          if ny >= 1 and ny <= h and nx >= 1 and nx <= w then
            local c = grid[ny][nx]
            if c == '|' then
              trees = trees + 1
            elseif c == '#' then
              lumber = lumber + 1
            end
          end
        end
      end
    end
    return trees, lumber
  end

  local function step()
    local nxt = {}
    for y = 1, h do
      nxt[y] = {}
      for x = 1, w do
        local c = grid[y][x]
        local trees, lumber = count_adj(y, x)
        if c == '.' then
          nxt[y][x] = (trees >= 3) and '|' or '.'
        elseif c == '|' then
          nxt[y][x] = (lumber >= 3) and '#' or '|'
        else
          nxt[y][x] = (trees >= 1 and lumber >= 1) and '#' or '.'
        end
      end
    end
    grid = nxt
  end

  local g1 = {}
  for y = 1, h do
    g1[y] = {}
    for x = 1, w do
      g1[y][x] = grid[y][x]
    end
  end

  for _ = 1, 10 do
    step()
  end

  local trees, lumber = 0, 0
  for y = 1, h do
    for x = 1, w do
      if grid[y][x] == '|' then
        trees = trees + 1
      elseif grid[y][x] == '#' then
        lumber = lumber + 1
      end
    end
  end
  local part1 = trees * lumber

  grid = g1
  local seen = {}
  local history = {}
  local t = 0
  local part2 = nil
  while part2 == nil do
    local key = {}
    for y = 1, h do
      for x = 1, w do
        key[#key + 1] = grid[y][x]
      end
    end
    local sig = table.concat(key)
    if seen[sig] then
      local prev_t = seen[sig]
      local cycle_len = t - prev_t
      local rem = (1000000000 - prev_t) % cycle_len
      part2 = history[prev_t + rem]
      break
    end
    seen[sig] = t
    local trees2, lumber2 = 0, 0
    for y = 1, h do
      for x = 1, w do
        if grid[y][x] == '|' then
          trees2 = trees2 + 1
        elseif grid[y][x] == '#' then
          lumber2 = lumber2 + 1
        end
      end
    end
    history[t] = trees2 * lumber2
    step()
    t = t + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day18(path)
end
