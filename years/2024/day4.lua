return function(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = lines[1] and #lines[1] or 0
  local g = {}
  for r = 1, rows do
    g[r] = {}
    local line = lines[r]
    for c = 1, cols do
      g[r][c] = line:sub(c, c)
    end
  end

  local dirs = {
    { 0, 1 },
    { 0, -1 },
    { 1, 0 },
    { -1, 0 },
    { 1, 1 },
    { 1, -1 },
    { -1, 1 },
    { -1, -1 },
  }

  local part1 = 0
  for r = 1, rows do
    for c = 1, cols do
      if g[r][c] == 'X' then
        for _, d in ipairs(dirs) do
          local dr, dc = d[1], d[2]
          if g[r + dr] and g[r + dr][c + dc] == 'M' and g[r + 2 * dr] and g[r + 2 * dr][c + 2 * dc] == 'A' and g[r + 3 * dr] and g[r + 3 * dr][c + 3 * dc] == 'S' then
            part1 = part1 + 1
          end
        end
      end
    end
  end

  local part2 = 0
  for r = 2, rows - 1 do
    for c = 2, cols - 1 do
      if g[r][c] == 'A' then
        local nw, se = g[r - 1][c - 1], g[r + 1][c + 1]
        local ne, sw = g[r - 1][c + 1], g[r + 1][c - 1]
        local ok1 = (nw == 'M' and se == 'S') or (nw == 'S' and se == 'M')
        local ok2 = (ne == 'M' and sw == 'S') or (ne == 'S' and sw == 'M')
        if ok1 and ok2 then
          part2 = part2 + 1
        end
      end
    end
  end

  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
