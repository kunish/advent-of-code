local DR = { [1] = 0, [2] = 1, [3] = 0, [4] = -1 }
local DC = { [1] = 1, [2] = 0, [3] = -1, [4] = 0 }

local function left_dir(d)
  if d == 1 then
    return 4
  end
  return d - 1
end

local function right_dir(d)
  if d == 4 then
    return 1
  end
  return d + 1
end

local function heap_push(h, dist, st)
  local n = #h + 1
  h[n] = { dist, st }
  local idx = n
  while idx > 1 do
    local p = (idx - (idx % 2)) / 2
    if p < 1 then
      break
    end
    if h[p][1] <= h[idx][1] then
      break
    end
    h[p], h[idx] = h[idx], h[p]
    idx = p
  end
end

local function heap_pop(h)
  local n = #h
  if n == 0 then
    return nil
  end
  local root = h[1]
  h[1] = h[n]
  h[n] = nil
  n = n - 1
  local idx = 1
  while true do
    local l = idx * 2
    local r = l + 1
    local smallest = idx
    if l <= n and h[l][1] < h[smallest][1] then
      smallest = l
    end
    if r <= n and h[r][1] < h[smallest][1] then
      smallest = r
    end
    if smallest == idx then
      break
    end
    h[idx], h[smallest] = h[smallest], h[idx]
    idx = smallest
  end
  return root
end

local function dijkstra(grid, part2)
  local R = #grid
  local C = #grid[1]
  local function cell(r, c)
    return tonumber(grid[r]:sub(c, c))
  end

  local min_straight = part2 and 4 or 1
  local max_straight = part2 and 10 or 3

  local best = {}
  local function key(r, c, d, s)
    return r .. ',' .. c .. ',' .. d .. ',' .. s
  end

  local function relax(r, c, d, s, dist)
    local k = key(r, c, d, s)
    local prev = best[k]
    if not prev or dist < prev then
      best[k] = dist
      return true
    end
    return false
  end

  local h = {}
  -- start: step east or south from (1,1)
  if C >= 2 then
    local cst = cell(1, 2)
    if relax(1, 2, 1, 1, cst) then
      heap_push(h, cst, { 1, 2, 1, 1 })
    end
  end
  if R >= 2 then
    local cst = cell(2, 1)
    if relax(2, 1, 2, 1, cst) then
      heap_push(h, cst, { 2, 1, 2, 1 })
    end
  end

  local answer
  while #h > 0 do
    local cur = heap_pop(h)
    local dist = cur[1]
    local st = cur[2]
    local r, c, d, s = st[1], st[2], st[3], st[4]
    local k = key(r, c, d, s)
    if best[k] ~= dist then
      -- stale
    else
      if r == R and c == C then
        if not part2 or s >= min_straight then
          answer = dist
          break
        end
      end

      -- straight
      if s < max_straight then
        local nr = r + DR[d]
        local nc = c + DC[d]
        if nr >= 1 and nr <= R and nc >= 1 and nc <= C then
          local ndist = dist + cell(nr, nc)
          local ns = s + 1
          if relax(nr, nc, d, ns, ndist) then
            heap_push(h, ndist, { nr, nc, d, ns })
          end
        end
      end

      -- turns (only if allowed to turn)
      if not part2 or s >= min_straight then
        local ld = left_dir(d)
        local rd = right_dir(d)
        local dirs = { ld, rd }
        local t = 1
        while t <= 2 do
          local nd = dirs[t]
          local nr = r + DR[nd]
          local nc = c + DC[nd]
          if nr >= 1 and nr <= R and nc >= 1 and nc <= C then
            local ndist = dist + cell(nr, nc)
            if relax(nr, nc, nd, 1, ndist) then
              heap_push(h, ndist, { nr, nc, nd, 1 })
            end
          end
          t = t + 1
        end
      end
    end
  end

  return answer
end

return function(path)
  local lines = readLines(path)
  local p1 = dijkstra(lines, false)
  local p2 = dijkstra(lines, true)
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
