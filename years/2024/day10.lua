return function(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = lines[1] and #lines[1] or 0
  local g = {}
  for r = 1, rows do
    g[r] = {}
    local line = lines[r]
    for c = 1, cols do
      g[r][c] = tonumber(line:sub(c, c))
    end
  end

  local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }

  local function dfs_score(r, c, seen9)
    local h = g[r][c]
    if h == 9 then
      seen9[r .. ',' .. c] = true
      return
    end
    for _, d in ipairs(dirs) do
      local nr, nc = r + d[1], c + d[2]
      if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols then
        if g[nr][nc] == h + 1 then
          dfs_score(nr, nc, seen9)
        end
      end
    end
  end

  local function dfs_rating(r, c)
    local h = g[r][c]
    if h == 9 then
      return 1
    end
    local total = 0
    for _, d in ipairs(dirs) do
      local nr, nc = r + d[1], c + d[2]
      if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols then
        if g[nr][nc] == h + 1 then
          total = total + dfs_rating(nr, nc)
        end
      end
    end
    return total
  end

  local part1, part2 = 0, 0
  for r = 1, rows do
    for c = 1, cols do
      if g[r][c] == 0 then
        local seen9 = {}
        dfs_score(r, c, seen9)
        for _ in pairs(seen9) do
          part1 = part1 + 1
        end
        part2 = part2 + dfs_rating(r, c)
      end
    end
  end

  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
