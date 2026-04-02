return function(path)
  local lines = readLines(path)

  local function rev(s)
    local t = {}
    local z = #s
    while z >= 1 do
      t[#t + 1] = string.sub(s, z, z)
      z = z - 1
    end
    return table.concat(t)
  end

  local tiles = {}
  local li = 1
  while li <= #lines do
    local id = tonumber(string.match(lines[li] or '', '^Tile (%d+):'))
    if id then
      li = li + 1
      local g = {}
      local r = 1
      while r <= 10 and li <= #lines do
        if lines[li] == '' or string.match(lines[li], '^Tile') then
          break
        end
        g[r] = lines[li]
        r = r + 1
        li = li + 1
      end
      tiles[id] = g
    else
      li = li + 1
    end
  end

  local function edges10(g)
    local top = g[1]
    local bottom = g[10]
    local le = {}
    local ri = {}
    local rr = 1
    while rr <= 10 do
      le[rr] = string.sub(g[rr], 1, 1)
      ri[rr] = string.sub(g[rr], 10, 10)
      rr = rr + 1
    end
    return top, table.concat(ri), bottom, table.concat(le)
  end

  local function norm_edge(e)
    local r = rev(e)
    if e < r then
      return e
    end
    return r
  end

  local edge_count = {}
  for _, g in pairs(tiles) do
    local t, ri, b, le = edges10(g)
    local list = { t, ri, b, le }
    local k = 1
    while k <= 4 do
      local ne = norm_edge(list[k])
      edge_count[ne] = (edge_count[ne] or 0) + 1
      k = k + 1
    end
  end

  local part1 = 1
  for id, g in pairs(tiles) do
    local t, ri, b, le = edges10(g)
    local list = { t, ri, b, le }
    local border = 0
    local k = 1
    while k <= 4 do
      if edge_count[norm_edge(list[k])] == 1 then
        border = border + 1
      end
      k = k + 1
    end
    if border == 2 then
      part1 = part1 * id
    end
  end

  local function rotate_cw(g)
    local n = #g
    local out = {}
    local r = 1
    while r <= n do
      local row = {}
      local c = 1
      while c <= n do
        row[c] = string.sub(g[n - c + 1], r, r)
        c = c + 1
      end
      out[r] = table.concat(row)
      r = r + 1
    end
    return out
  end

  local function flip_h(g)
    local out = {}
    local r = 1
    while r <= #g do
      out[r] = rev(g[r])
      r = r + 1
    end
    return out
  end

  local function all_orientations(g)
    local res = {}
    local cur = g
    local o = 1
    while o <= 4 do
      res[#res + 1] = cur
      cur = rotate_cw(cur)
      o = o + 1
    end
    cur = flip_h(g)
    o = 1
    while o <= 4 do
      res[#res + 1] = cur
      cur = rotate_cw(cur)
      o = o + 1
    end
    return res
  end

  local orient_cache = {}
  for id, g in pairs(tiles) do
    orient_cache[id] = all_orientations(g)
  end

  local function inner8(g)
    local out = {}
    local r = 2
    while r <= 9 do
      out[r - 1] = string.sub(g[r], 2, 9)
      r = r + 1
    end
    return out
  end

  local ids = {}
  local ni = 0
  for id, _ in pairs(tiles) do
    ni = ni + 1
    ids[ni] = id
  end
  local nside = 1
  while nside * nside < ni do
    nside = nside + 1
  end

  local function dfs(r, c, used, grid)
    if r > nside then
      return true
    end
    local nr = r
    local nc = c + 1
    if nc > nside then
      nr = r + 1
      nc = 1
    end

    local ti = 1
    while ti <= ni do
      local id = ids[ti]
      if not used[id] then
        local orients = orient_cache[id]
        local oi = 1
        while oi <= #orients do
          local g = orients[oi]
          local top, right, bottom, left = edges10(g)
          local ok = true
          if r > 1 then
            if grid[r - 1][c].bottom ~= top then
              ok = false
            end
          else
            if edge_count[norm_edge(top)] ~= 1 then
              ok = false
            end
          end
          if ok then
            if c > 1 then
              if grid[r][c - 1].right ~= left then
                ok = false
              end
            else
              if edge_count[norm_edge(left)] ~= 1 then
                ok = false
              end
            end
          end
          if ok then
            if r == nside then
              if edge_count[norm_edge(bottom)] ~= 1 then
                ok = false
              end
            end
          end
          if ok then
            if c == nside then
              if edge_count[norm_edge(right)] ~= 1 then
                ok = false
              end
            end
          end

          if ok then
            used[id] = true
            grid[r][c] = { g = g, bottom = bottom, right = right }
            if dfs(nr, nc, used, grid) then
              return true
            end
            used[id] = nil
            grid[r][c] = nil
          end
          oi = oi + 1
        end
      end
      ti = ti + 1
    end
    return false
  end

  local used = {}
  local grid = {}
  local gr = 1
  while gr <= nside do
    grid[gr] = {}
    gr = gr + 1
  end
  local placed = nil
  if dfs(1, 1, used, grid) then
    placed = grid
  end

  local image = {}
  local ir = 1
  while ir <= nside * 8 do
    image[ir] = string.rep('.', nside * 8)
    ir = ir + 1
  end

  if placed then
    local br = 1
    while br <= nside do
      local bc = 1
      while bc <= nside do
        local cell = placed[br][bc]
        local inner = inner8(cell.g)
        local lr = 1
        while lr <= 8 do
          local gr2 = (br - 1) * 8 + lr
          local row = image[gr2]
          local start = (bc - 1) * 8 + 1
          local before = string.sub(row, 1, start - 1)
          local after = string.sub(row, start + 8)
          image[gr2] = before .. inner[lr] .. after
          lr = lr + 1
        end
        bc = bc + 1
      end
      br = br + 1
    end
  end

  local monster = {
    { 0, 18 },
    { 1, 0 },
    { 1, 5 },
    { 1, 6 },
    { 1, 11 },
    { 1, 12 },
    { 1, 17 },
    { 1, 18 },
    { 1, 19 },
    { 2, 1 },
    { 2, 4 },
    { 2, 7 },
    { 2, 10 },
    { 2, 13 },
    { 2, 16 },
  }

  local function count_hashes(g)
    local h = 0
    local r = 1
    while r <= #g do
      local c = 1
      while c <= #g[r] do
        if string.sub(g[r], c, c) == '#' then
          h = h + 1
        end
        c = c + 1
      end
      r = r + 1
    end
    return h
  end

  local total_h = count_hashes(image)
  local best_monsters = 0
  local olist = all_orientations(image)
  local oi = 1
  while oi <= #olist do
    local g = olist[oi]
    local rows = #g
    local cols = #g[1]
    local cnt = 0
    local sr = 1
    while sr <= rows - 2 do
      local sc = 1
      while sc <= cols - 19 do
        local found = true
        local mi = 1
        while mi <= #monster do
          local dr = monster[mi][1]
          local dc = monster[mi][2]
          local ch = string.sub(g[sr + dr], sc + dc, sc + dc)
          if ch ~= '#' then
            found = false
            break
          end
          mi = mi + 1
        end
        if found then
          cnt = cnt + 1
        end
        sc = sc + 1
      end
      sr = sr + 1
    end
    if cnt > best_monsters then
      best_monsters = cnt
    end
    oi = oi + 1
  end

  local part2 = total_h - best_monsters * 15

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
