return function(path)
  local G = readLines(path)
  local R = #G
  local C = #G[1]

  local function gat(rr, cc)
    return G[rr + 1]:sub(cc + 1, cc + 1)
  end

  local c = 0
  while gat(0, c) == '#' do
    c = c + 1
  end
  local sc = c

  local mx = (R - 2) * (C - 2)
  local bad_cells = {}
  for t = 0, mx do
    local BAD = {}
    for rr = 0, R - 1 do
      for cc = 0, C - 1 do
        local ch = gat(rr, cc)
        if ch == '>' then
          local nc = 1 + ((cc - 1 + t) % (C - 2))
          BAD[rr .. ',' .. nc] = true
        elseif ch == 'v' then
          local nr = 1 + ((rr - 1 + t) % (R - 2))
          BAD[nr .. ',' .. cc] = true
        elseif ch == '<' then
          local nc = 1 + ((cc - 1 - t) % (C - 2))
          BAD[rr .. ',' .. nc] = true
        elseif ch == '^' then
          local nr = 1 + ((rr - 1 - t) % (R - 2))
          BAD[nr .. ',' .. cc] = true
        end
      end
    end
    bad_cells[t + 1] = BAD
  end

  local p1 = false
  local seen = {}
  local q = {}
  local qh, qt = 1, 0

  local function push(r, c, t, got_end, got_start)
    local key = r .. ',' .. c .. ',' .. t .. ',' .. tostring(got_end) .. ',' .. tostring(got_start)
    if seen[key] then
      return
    end
    seen[key] = true
    qt = qt + 1
    q[qt] = r
    qt = qt + 1
    q[qt] = c
    qt = qt + 1
    q[qt] = t
    qt = qt + 1
    q[qt] = got_end
    qt = qt + 1
    q[qt] = got_start
  end

  push(0, sc, 0, false, false)

  while qh <= qt do
    local r = q[qh]
    qh = qh + 1
    local c = q[qh]
    qh = qh + 1
    local t = q[qh]
    qh = qh + 1
    local got_end = q[qh]
    qh = qh + 1
    local got_start = q[qh]
    qh = qh + 1

    if not (r >= 0 and r < R and c >= 0 and c < C and gat(r, c) ~= '#') then
      goto cont
    end

    if r == R - 1 and got_end and got_start then
      print(string.format('Part 2: %d', t))
      return
    end

    if r == R - 1 and not p1 then
      print(string.format('Part 1: %d', t))
      p1 = true
    end

    local ge, gs = got_end, got_start
    if r == R - 1 then
      ge = true
    end
    if r == 0 and ge then
      gs = true
    end

    local BAD = bad_cells[t + 2]

    local function try_move(nr, nc, nt)
      if not (nr >= 0 and nr < R and nc >= 0 and nc < C and gat(nr, nc) ~= '#') then
        return
      end
      if BAD[nr .. ',' .. nc] then
        return
      end
      push(nr, nc, nt, ge, gs)
    end

    try_move(r, c, t + 1)
    try_move(r + 1, c, t + 1)
    try_move(r - 1, c, t + 1)
    try_move(r, c + 1, t + 1)
    try_move(r, c - 1, t + 1)

    ::cont::
  end
end
