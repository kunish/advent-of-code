local function count_occupied(grid, r, c, h, w, part2)
  local dirs = {
    { -1, -1 },
    { -1, 0 },
    { -1, 1 },
    { 0, -1 },
    { 0, 1 },
    { 1, -1 },
    { 1, 0 },
    { 1, 1 },
  }
  local cnt = 0
  local d = 1
  while d <= #dirs do
    local dr, dc = dirs[d][1], dirs[d][2]
    local rr, cc = r + dr, c + dc
    if part2 then
      while rr >= 1 and rr <= h and cc >= 1 and cc <= w do
        local ch = grid[rr]:sub(cc, cc)
        if ch == 'L' or ch == '#' then
          if ch == '#' then
            cnt = cnt + 1
          end
          break
        end
        rr = rr + dr
        cc = cc + dc
      end
    else
      if rr >= 1 and rr <= h and cc >= 1 and cc <= w then
        if grid[rr]:sub(cc, cc) == '#' then
          cnt = cnt + 1
        end
      end
    end
    d = d + 1
  end
  return cnt
end

local function step(grid, part2, limit)
  local h = #grid
  local w = #grid[1]
  local nextg = {}
  local r = 1
  while r <= h do
    local row = grid[r]
    local out = {}
    local c = 1
    while c <= w do
      local ch = row:sub(c, c)
      if ch == '.' then
        out[c] = '.'
      else
        local occ = count_occupied(grid, r, c, h, w, part2)
        if ch == 'L' and occ == 0 then
          out[c] = '#'
        elseif ch == '#' and occ >= limit then
          out[c] = 'L'
        else
          out[c] = ch
        end
      end
      c = c + 1
    end
    nextg[r] = table.concat(out)
    r = r + 1
  end
  return nextg
end

local function stable_run(grid, part2, limit)
  local cur = grid
  while true do
    local nxt = step(cur, part2, limit)
    local same = true
    local i = 1
    while i <= #cur do
      if cur[i] ~= nxt[i] then
        same = false
        break
      end
      i = i + 1
    end
    if same then
      return cur
    end
    cur = nxt
  end
end

local function count_hashes(grid)
  local t = 0
  local r = 1
  while r <= #grid do
    local row = grid[r]
    local c = 1
    while c <= #row do
      if row:sub(c, c) == '#' then
        t = t + 1
      end
      c = c + 1
    end
    r = r + 1
  end
  return t
end

return function(path)
  local lines = readLines(path)
  local grid = {}
  local i = 1
  while i <= #lines do
    if lines[i] ~= '' then
      grid[#grid + 1] = lines[i]
    end
    i = i + 1
  end

  local g1 = stable_run(grid, false, 4)
  local part1 = count_hashes(g1)
  local g2 = stable_run(grid, true, 5)
  local part2 = count_hashes(g2)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
