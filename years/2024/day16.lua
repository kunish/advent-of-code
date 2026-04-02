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

  local ddr = { [0] = 0, [1] = 1, [2] = 0, [3] = -1 }
  local ddc = { [0] = 1, [1] = 0, [2] = -1, [3] = 0 }

  local function wall(r, c)
    return grid[r][c] == '#'
  end

  local INF = 1e18

  local function kf(r, c, d)
    return r .. ',' .. c .. ',' .. d
  end

  local function dijkstra_forward()
    local dist = {}
    local function get(r, c, d)
      return dist[kf(r, c, d)] or INF
    end
    local function set(r, c, d, v)
      dist[kf(r, c, d)] = v
    end

    local heap = { { 0, sr, sc, 0 } }
    local function hpush(item)
      heap[#heap + 1] = item
      local i = #heap
      while i > 1 do
        local p = math.floor(i / 2)
        if heap[p][1] <= heap[i][1] then
          break
        end
        heap[p], heap[i] = heap[i], heap[p]
        i = p
      end
    end
    local function hpop()
      if #heap == 0 then
        return nil
      end
      local rmin = heap[1]
      local last = heap[#heap]
      heap[#heap] = nil
      if #heap == 0 then
        return rmin
      end
      heap[1] = last
      local i = 1
      while true do
        local l, r2 = i * 2, i * 2 + 1
        local sm = i
        if l <= #heap and heap[l][1] < heap[sm][1] then
          sm = l
        end
        if r2 <= #heap and heap[r2][1] < heap[sm][1] then
          sm = r2
        end
        if sm == i then
          break
        end
        heap[i], heap[sm] = heap[sm], heap[i]
        i = sm
      end
      return rmin
    end

    set(sr, sc, 0, 0)
    while #heap > 0 do
      local cur = hpop()
      local cost, r, c, d = cur[1], cur[2], cur[3], cur[4]
      if cost ~= get(r, c, d) then
        -- stale
      else
        local nd1 = (d + 3) % 4
        local nd2 = (d + 1) % 4
        if get(r, c, nd1) > cost + 1000 then
          set(r, c, nd1, cost + 1000)
          hpush({ cost + 1000, r, c, nd1 })
        end
        if get(r, c, nd2) > cost + 1000 then
          set(r, c, nd2, cost + 1000)
          hpush({ cost + 1000, r, c, nd2 })
        end
        local nr, nc = r + ddr[d], c + ddc[d]
        if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols and not wall(nr, nc) then
          if get(nr, nc, d) > cost + 1 then
            set(nr, nc, d, cost + 1)
            hpush({ cost + 1, nr, nc, d })
          end
        end
      end
    end
    return dist
  end

  local function dijkstra_backward()
    local dist = {}
    local function get(r, c, d)
      return dist[kf(r, c, d)] or INF
    end
    local function set(r, c, d, v)
      dist[kf(r, c, d)] = v
    end

    local heap = {}
    local function hpush(item)
      heap[#heap + 1] = item
      local i = #heap
      while i > 1 do
        local p = math.floor(i / 2)
        if heap[p][1] <= heap[i][1] then
          break
        end
        heap[p], heap[i] = heap[i], heap[p]
        i = p
      end
    end
    local function hpop()
      if #heap == 0 then
        return nil
      end
      local rmin = heap[1]
      local last = heap[#heap]
      heap[#heap] = nil
      if #heap == 0 then
        return rmin
      end
      heap[1] = last
      local i = 1
      while true do
        local l, r2 = i * 2, i * 2 + 1
        local sm = i
        if l <= #heap and heap[l][1] < heap[sm][1] then
          sm = l
        end
        if r2 <= #heap and heap[r2][1] < heap[sm][1] then
          sm = r2
        end
        if sm == i then
          break
        end
        heap[i], heap[sm] = heap[sm], heap[i]
        i = sm
      end
      return rmin
    end

    for d = 0, 3 do
      set(er, ec, d, 0)
      hpush({ 0, er, ec, d })
    end

    while #heap > 0 do
      local cur = hpop()
      local cost, r, c, d = cur[1], cur[2], cur[3], cur[4]
      if cost ~= get(r, c, d) then
      else
        local pr, pc = r - ddr[d], c - ddc[d]
        if pr >= 1 and pr <= rows and pc >= 1 and pc <= cols and not wall(pr, pc) then
          if get(pr, pc, d) > cost + 1 then
            set(pr, pc, d, cost + 1)
            hpush({ cost + 1, pr, pc, d })
          end
        end
        local d2a = (d + 1) % 4
        local d2b = (d + 3) % 4
        if get(r, c, d2a) > cost + 1000 then
          set(r, c, d2a, cost + 1000)
          hpush({ cost + 1000, r, c, d2a })
        end
        if get(r, c, d2b) > cost + 1000 then
          set(r, c, d2b, cost + 1000)
          hpush({ cost + 1000, r, c, d2b })
        end
      end
    end
    return dist
  end

  local distF = dijkstra_forward()
  local distB = dijkstra_backward()

  local function getF(r, c, d)
    return distF[kf(r, c, d)] or INF
  end
  local function getB(r, c, d)
    return distB[kf(r, c, d)] or INF
  end

  local best_end = INF
  for d = 0, 3 do
    local v = getF(er, ec, d)
    if v < best_end then
      best_end = v
    end
  end

  local tiles = {}
  for r = 1, rows do
    for c = 1, cols do
      if not wall(r, c) then
        for d = 0, 3 do
          if getF(r, c, d) + getB(r, c, d) == best_end then
            tiles[r .. ',' .. c] = true
            break
          end
        end
      end
    end
  end

  local cnt = 0
  for _ in pairs(tiles) do
    cnt = cnt + 1
  end

  print(string.format('Part 1: %.0f', best_end))
  print(string.format('Part 2: %d', cnt))
end
