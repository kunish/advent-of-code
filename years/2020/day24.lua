return function(path)
  local lines = readLines(path)

  local dirs = {
    e = { 1, -1, 0 },
    se = { 0, -1, 1 },
    sw = { -1, 0, 1 },
    w = { -1, 1, 0 },
    nw = { 0, 1, -1 },
    ne = { 1, 0, -1 },
  }

  local nbrs = {
    { 1, -1, 0 },
    { 0, -1, 1 },
    { -1, 0, 1 },
    { -1, 1, 0 },
    { 0, 1, -1 },
    { 1, 0, -1 },
  }

  local function key(q, r, s)
    return q .. ',' .. r .. ',' .. s
  end

  local function walk(line)
    local q, r, s = 0, 0, 0
    local i = 1
    while i <= #line do
      local c2 = string.sub(line, i, i + 1)
      local d = nil
      if c2 == 'se' or c2 == 'sw' or c2 == 'nw' or c2 == 'ne' then
        d = dirs[c2]
        i = i + 2
      else
        d = dirs[string.sub(line, i, i)]
        i = i + 1
      end
      q = q + d[1]
      r = r + d[2]
      s = s + d[3]
    end
    return q, r, s
  end

  local black = {}
  local li = 1
  while li <= #lines do
    if lines[li] ~= '' then
      local q, r, s = walk(lines[li])
      local k = key(q, r, s)
      if black[k] then
        black[k] = nil
      else
        black[k] = { q, r, s }
      end
    end
    li = li + 1
  end

  local part1 = 0
  for _ in pairs(black) do
    part1 = part1 + 1
  end

  local function neighbor_black_cnt(q, r, s, bset)
    local cnt = 0
    local ni = 1
    while ni <= 6 do
      local nq = q + nbrs[ni][1]
      local nr = r + nbrs[ni][2]
      local ns = s + nbrs[ni][3]
      if bset[key(nq, nr, ns)] then
        cnt = cnt + 1
      end
      ni = ni + 1
    end
    return cnt
  end

  local day = 1
  while day <= 100 do
    local candidates = {}
    for k, t in pairs(black) do
      candidates[k] = t
      local ni = 1
      while ni <= 6 do
        local nq = t[1] + nbrs[ni][1]
        local nr = t[2] + nbrs[ni][2]
        local ns = t[3] + nbrs[ni][3]
        local nk = key(nq, nr, ns)
        if not candidates[nk] then
          candidates[nk] = { nq, nr, ns }
        end
        ni = ni + 1
      end
    end

    local nxt = {}
    for k, t in pairs(candidates) do
      local q, r, s = t[1], t[2], t[3]
      local is_black = black[k] ~= nil
      local cnt = neighbor_black_cnt(q, r, s, black)
      if is_black then
        if cnt == 1 or cnt == 2 then
          nxt[k] = t
        end
      else
        if cnt == 2 then
          nxt[k] = t
        end
      end
    end
    black = nxt
    day = day + 1
  end

  local part2 = 0
  for _ in pairs(black) do
    part2 = part2 + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
