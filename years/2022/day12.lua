local function day12(path)
  local lines = readLines(path)
  local n = #lines
  local m = #(lines[1] or '')

  local grid = {}
  local sx, sy, ex, ey
  for i = 1, n do
    local row = {}
    local line = lines[i]
    for j = 1, m do
      local c = line:sub(j, j)
      if c == 'S' then
        sx = i
        sy = j
        c = 'a'
      elseif c == 'E' then
        ex = i
        ey = j
        c = 'z'
      end
      row[j] = string.byte(c) - string.byte('a')
    end
    grid[i] = row
  end

  local function bfs_from_start(start_i, start_j)
    local dist = {}
    local q = {}
    local qh, qt = 1, 1
    q[1] = { start_i, start_j }
    local key = function(a, b)
      return a * 10000 + b
    end
    dist[key(start_i, start_j)] = 0

    while qh <= qt do
      local cur = q[qh]
      qh = qh + 1
      local ci = cur[1]
      local cj = cur[2]
      local d = dist[key(ci, cj)]
      local h = grid[ci][cj]
      local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
      for t = 1, 4 do
        local di = dirs[t][1]
        local dj = dirs[t][2]
        local ni = ci + di
        local nj = cj + dj
        if ni >= 1 and ni <= n and nj >= 1 and nj <= m then
          local nh = grid[ni][nj]
          if nh <= h + 1 then
            local k = key(ni, nj)
            if dist[k] == nil then
              dist[k] = d + 1
              qt = qt + 1
              q[qt] = { ni, nj }
            end
          end
        end
      end
    end
    return dist[key(ex, ey)]
  end

  local part1 = bfs_from_start(sx, sy)

  local dist2 = {}
  local q2 = {}
  local qh2, qt2 = 1, 1
  q2[1] = { ex, ey }
  local function key2(a, b)
    return a * 10000 + b
  end
  dist2[key2(ex, ey)] = 0

  while qh2 <= qt2 do
    local cur = q2[qh2]
    qh2 = qh2 + 1
    local ci = cur[1]
    local cj = cur[2]
    local d = dist2[key2(ci, cj)]
    local h = grid[ci][cj]
    local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
    for t = 1, 4 do
      local ni = ci + dirs[t][1]
      local nj = cj + dirs[t][2]
      if ni >= 1 and ni <= n and nj >= 1 and nj <= m then
        local nh = grid[ni][nj]
        if h <= nh + 1 then
          local k = key2(ni, nj)
          if dist2[k] == nil then
            dist2[k] = d + 1
            qt2 = qt2 + 1
            q2[qt2] = { ni, nj }
          end
        end
      end
    end
  end

  local part2 = nil
  for i = 1, n do
    for j = 1, m do
      local line = lines[i]
      local oc = line:sub(j, j)
      if oc == 'a' or oc == 'S' then
        local dd = dist2[key2(i, j)]
        if dd and (part2 == nil or dd < part2) then
          part2 = dd
        end
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2 or 0))
end

return function(p)
  return day12(p)
end
