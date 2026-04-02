local function day8(path)
  local lines = readLines(path)
  local n = #lines
  local m = #(lines[1] or '')
  local g = {}
  for i = 1, n do
    local row = {}
    local line = lines[i]
    for j = 1, m do
      row[j] = tonumber(line:sub(j, j))
    end
    g[i] = row
  end

  local function visible(ii, jj)
    local h = g[ii][jj]
    local ok = false
    local a = true
    for i = 1, ii - 1 do
      if g[i][jj] >= h then
        a = false
        break
      end
    end
    if a then
      ok = true
    end
    a = true
    for i = ii + 1, n do
      if g[i][jj] >= h then
        a = false
        break
      end
    end
    if a then
      ok = true
    end
    a = true
    for j = 1, jj - 1 do
      if g[ii][j] >= h then
        a = false
        break
      end
    end
    if a then
      ok = true
    end
    a = true
    for j = jj + 1, m do
      if g[ii][j] >= h then
        a = false
        break
      end
    end
    if a then
      ok = true
    end
    return ok
  end

  local part1 = 0
  for i = 1, n do
    for j = 1, m do
      if i == 1 or i == n or j == 1 or j == m or visible(i, j) then
        part1 = part1 + 1
      end
    end
  end

  local function view_up(ii, jj)
    local h = g[ii][jj]
    local d = 0
    for i = ii - 1, 1, -1 do
      d = d + 1
      if g[i][jj] >= h then
        break
      end
    end
    return d
  end

  local function view_down(ii, jj)
    local h = g[ii][jj]
    local d = 0
    for i = ii + 1, n do
      d = d + 1
      if g[i][jj] >= h then
        break
      end
    end
    return d
  end

  local function view_left(ii, jj)
    local h = g[ii][jj]
    local d = 0
    for j = jj - 1, 1, -1 do
      d = d + 1
      if g[ii][j] >= h then
        break
      end
    end
    return d
  end

  local function view_right(ii, jj)
    local h = g[ii][jj]
    local d = 0
    for j = jj + 1, m do
      d = d + 1
      if g[ii][j] >= h then
        break
      end
    end
    return d
  end

  local part2 = 0
  for i = 1, n do
    for j = 1, m do
      local sc = view_up(i, j) * view_down(i, j) * view_left(i, j) * view_right(i, j)
      if sc > part2 then
        part2 = sc
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day8(p)
end
