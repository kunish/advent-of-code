return function(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = #lines[1]
  local grid = {}
  local sr, sc, er, ec
  for r = 1, rows do
    grid[r] = {}
    for c = 1, cols do
      local ch = lines[r]:sub(c, c)
      grid[r][c] = ch
      if ch == 'S' then
        sr, sc = r, c
      elseif ch == 'E' then
        er, ec = r, c
      end
    end
  end

  local function is_track(r, c)
    local ch = grid[r][c]
    return ch == '.' or ch == 'S' or ch == 'E'
  end

  local function bfs_from(srr, scc)
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
    local q = { { srr, scc } }
    set(srr, scc, 0)
    local qi = 1
    while qi <= #q do
      local r, c = q[qi][1], q[qi][2]
      qi = qi + 1
      local d = get(r, c)
      for _, dd in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
        local nr, nc = r + dd[1], c + dd[2]
        if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols and is_track(nr, nc) and not get(nr, nc) then
          set(nr, nc, d + 1)
          q[#q + 1] = { nr, nc }
        end
      end
    end
    return dist
  end

  local distS = bfs_from(sr, sc)
  local distE = bfs_from(er, ec)
  local function ds(r, c)
    return distS[r .. ',' .. c]
  end
  local function de(r, c)
    return distE[r .. ',' .. c]
  end
  local best = ds(er, ec)

  local track = {}
  for r = 1, rows do
    for c = 1, cols do
      if is_track(r, c) then
        track[#track + 1] = { r, c }
      end
    end
  end

  local function count_cheats(maxd, save_at_least)
    local cnt = 0
    for i = 1, #track do
      for j = i + 1, #track do
        local r1, c1 = track[i][1], track[i][2]
        local r2, c2 = track[j][1], track[j][2]
        local man = math.abs(r1 - r2) + math.abs(c1 - c2)
        if man <= maxd then
          local d1s, d2s = ds(r1, c1), ds(r2, c2)
          local d1e, d2e = de(r1, c1), de(r2, c2)
          if d1s and d2s and d1e and d2e then
            local t1 = d1s + man + d2e
            local t2 = d2s + man + d1e
            local use = math.min(t1, t2)
            local saving = best - use
            if saving >= save_at_least then
              cnt = cnt + 1
            end
          end
        end
      end
    end
    return cnt
  end

  print(string.format('Part 1: %d', count_cheats(2, 100)))
  print(string.format('Part 2: %d', count_cheats(20, 100)))
end
