return function(path)
  local lines = readLines(path)
  local N = 71
  local coords = {}
  for _, line in ipairs(lines) do
    local x, y = line:match('(%d+),(%d+)')
    if x then
      coords[#coords + 1] = { tonumber(x), tonumber(y) }
    end
  end

  local function bfs(blocked)
    local dist = {}
    local function k(r, c)
      return r .. ',' .. c
    end
    local function get(r, c)
      return dist[k(r, c)]
    end
    local function set(r, c, v)
      dist[k(r, c)] = v
    end
    local q = { { 0, 0 } }
    set(0, 0, 0)
    local qi = 1
    while qi <= #q do
      local r, c = q[qi][1], q[qi][2]
      qi = qi + 1
      local d = get(r, c)
      for _, dd in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
        local nr, nc = r + dd[1], c + dd[2]
        if nr >= 0 and nr < N and nc >= 0 and nc < N and not blocked[k(nr, nc)] and get(nr, nc) == nil then
          set(nr, nc, d + 1)
          q[#q + 1] = { nr, nc }
        end
      end
    end
    return get(N - 1, N - 1)
  end

  local function blocked_set(n)
    local b = {}
    for i = 1, n do
      local xy = coords[i]
      b[xy[2] .. ',' .. xy[1]] = true
    end
    return b
  end

  local d1024 = bfs(blocked_set(1024))
  print(string.format('Part 1: %d', d1024))

  local lo, hi = 1, #coords
  while lo < hi do
    local mid = math.floor((lo + hi) / 2)
    if bfs(blocked_set(mid)) == nil then
      hi = mid
    else
      lo = mid + 1
    end
  end
  local xy = coords[lo]
  print(string.format('Part 2: %d,%d', xy[1], xy[2]))
end
