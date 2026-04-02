local function neighbors4(grid, R, C, r, c, part2)
  local ch = grid[r]:sub(c, c)
  local out = {}
  if not part2 then
    if ch == '^' then
      out[1] = { r - 1, c }
      return out
    end
    if ch == 'v' then
      out[1] = { r + 1, c }
      return out
    end
    if ch == '<' then
      out[1] = { r, c - 1 }
      return out
    end
    if ch == '>' then
      out[1] = { r, c + 1 }
      return out
    end
  end
  local dirs = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
  local ni = 1
  local di = 1
  while di <= 4 do
    local rr = r + dirs[di][1]
    local cc = c + dirs[di][2]
    if rr >= 1 and rr <= R and cc >= 1 and cc <= C then
      local t = grid[rr]:sub(cc, cc)
      if t ~= '#' then
        out[ni] = { rr, cc }
        ni = ni + 1
      end
    end
    di = di + 1
  end
  return out
end

local function key(r, c)
  return r .. ',' .. c
end

local function find_start_end(grid)
  local R = #grid
  local C = #grid[1]
  local sr, sc, er, ec
  local c = 1
  while c <= C do
    if grid[1]:sub(c, c) == '.' then
      sr, sc = 1, c
    end
    if grid[R]:sub(c, c) == '.' then
      er, ec = R, c
    end
    c = c + 1
  end
  return sr, sc, er, ec
end

local function is_junction(grid, R, C, r, c)
  if r == 1 or r == R then
    return true
  end
  local nb = neighbors4(grid, R, C, r, c, true)
  local n = 0
  local i = 1
  while nb[i] do
    n = n + 1
    i = i + 1
  end
  return n ~= 2
end

local function longest_dfs(grid, R, C, sr, sc, er, ec, part2)
  local best = 0
  local visited = {}

  local function dfs(r, c, dist)
    if r == er and c == ec then
      if dist > best then
        best = dist
      end
      return
    end
    local k = key(r, c)
    if visited[k] then
      return
    end
    visited[k] = true
    local nb = neighbors4(grid, R, C, r, c, part2)
    local i = 1
    while nb[i] do
      local rr = nb[i][1]
      local cc = nb[i][2]
      dfs(rr, cc, dist + 1)
      i = i + 1
    end
    visited[k] = nil
  end

  dfs(sr, sc, 0)
  return best
end

local function build_graph(grid, R, C)
  local graph = {}
  local function ensure(k)
    if not graph[k] then
      graph[k] = {}
    end
  end

  local r = 1
  while r <= R do
    local c = 1
    while c <= C do
      if grid[r]:sub(c, c) ~= '#' then
        if is_junction(grid, R, C, r, c) then
          local k = key(r, c)
          ensure(k)
          local nb = neighbors4(grid, R, C, r, c, true)
          local i = 1
          while nb[i] do
            local nr, nc = nb[i][1], nb[i][2]
            local pr, pc = r, c
            local cr, cc = nr, nc
            local dist = 1
            while not is_junction(grid, R, C, cr, cc) do
              local n2 = neighbors4(grid, R, C, cr, cc, true)
              local nxt
              local j = 1
              while n2[j] do
                local tr, tc = n2[j][1], n2[j][2]
                if tr ~= pr or tc ~= pc then
                  nxt = n2[j]
                  break
                end
                j = j + 1
              end
              pr, pc = cr, cc
              cr, cc = nxt[1], nxt[2]
              dist = dist + 1
            end
            local nk = key(cr, cc)
            ensure(k)
            ensure(nk)
            graph[k][nk] = dist
            i = i + 1
          end
        end
      end
      c = c + 1
    end
    r = r + 1
  end
  return graph
end

local function longest_graph(graph, start, finish)
  local best = 0
  local visited = {}

  local function dfs(k, dist)
    if k == finish then
      if dist > best then
        best = dist
      end
      return
    end
    if visited[k] then
      return
    end
    visited[k] = true
    for nk, w in pairs(graph[k]) do
      dfs(nk, dist + w)
    end
    visited[k] = nil
  end

  dfs(start, 0)
  return best
end

return function(path)
  local lines = readLines(path)
  local grid = lines
  local R = #grid
  local C = #grid[1]
  local sr, sc, er, ec = find_start_end(grid)

  local p1 = longest_dfs(grid, R, C, sr, sc, er, ec, false)

  local graph = build_graph(grid, R, C)
  local p2 = longest_graph(graph, key(sr, sc), key(er, ec))

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
