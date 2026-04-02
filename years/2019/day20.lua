local D = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }

local function pkey(x, y)
  return x .. ',' .. y
end

local function parse(lines)
  local h = #lines
  local w = 0
  for i = 1, h do
    if #lines[i] > w then
      w = #lines[i]
    end
  end
  local g = {}
  for y = 1, h do
    local row = lines[y]
    if #row < w then
      row = row .. string.rep(' ', w - #row)
    end
    g[y] = row
  end

  local portals = {}
  local function add_portal(label, x, y)
    if not portals[label] then
      portals[label] = {}
    end
    local t = portals[label]
    t[#t + 1] = { x, y }
  end

  local seen = {}

  for y = 1, h do
    for x = 1, w do
      local c = g[y]:sub(x, x)
      if c >= 'A' and c <= 'Z' then
        local c2 = g[y]:sub(x + 1, x + 1)
        if c2 >= 'A' and c2 <= 'Z' then
          local lab = c .. c2
          local pk = pkey(x, y)
          if not seen[pk] then
            seen[pk] = true
            seen[pkey(x + 1, y)] = true
            if x > 1 and g[y]:sub(x - 1, x - 1) == '.' then
              add_portal(lab, x - 1, y)
            elseif x + 2 <= w and g[y]:sub(x + 2, x + 2) == '.' then
              add_portal(lab, x + 2, y)
            end
          end
        end
        local c3 = (y < h) and g[y + 1]:sub(x, x) or ' '
        if c3 >= 'A' and c3 <= 'Z' then
          local lab = c .. c3
          local pk = pkey(x, y)
          if not seen[pk] then
            seen[pk] = true
            seen[pkey(x, y + 1)] = true
            if y > 1 and g[y - 1]:sub(x, x) == '.' then
              add_portal(lab, x, y - 1)
            elseif y + 2 <= h and g[y + 2]:sub(x, x) == '.' then
              add_portal(lab, x, y + 2)
            end
          end
        end
      end
    end
  end

  return g, w, h, portals
end

local function is_outer(x, y, w, h)
  local ox = x <= 3 or x >= w - 2
  local oy = y <= 3 or y >= h - 2
  return ox or oy
end

local function bfs1(g, w, h, portals, start, goal)
  local q = { start }
  local qi, qn = 1, 1
  local dist = { [pkey(start[1], start[2])] = 0 }
  while qi <= qn do
    local x, y = q[qi][1], q[qi][2]
    qi = qi + 1
    local d = dist[pkey(x, y)]
    if x == goal[1] and y == goal[2] then
      return d
    end
    for i = 1, #D do
      local nx, ny = x + D[i][1], y + D[i][2]
      if nx >= 1 and nx <= w and ny >= 1 and ny <= h then
        local ch = g[ny]:sub(nx, nx)
        if ch == '.' then
          local nk = pkey(nx, ny)
          if dist[nk] == nil then
            dist[nk] = d + 1
            qn = qn + 1
            q[qn] = { nx, ny }
          end
        end
      end
    end
    for lab, pts in pairs(portals) do
      if lab ~= 'AA' and lab ~= 'ZZ' then
        for j = 1, #pts do
          local px, py = pts[j][1], pts[j][2]
          if px == x and py == y then
            local other = pts[3 - j]
            if other then
              local ox, oy = other[1], other[2]
              local ok = pkey(ox, oy)
              if dist[ok] == nil then
                dist[ok] = d + 1
                qn = qn + 1
                q[qn] = { ox, oy }
              end
            end
          end
        end
      end
    end
  end
  return nil
end

local function bfs2(g, w, h, portals, start, goal)
  local q = { { start[1], start[2], 0 } }
  local qi, qn = 1, 1
  local best = {}
  local function sk(x, y, lev)
    return x .. ',' .. y .. ',' .. lev
  end
  best[sk(start[1], start[2], 0)] = 0

  while qi <= qn do
    local x, y, lev = q[qi][1], q[qi][2], q[qi][3]
    qi = qi + 1
    local d = best[sk(x, y, lev)]

    if x == goal[1] and y == goal[2] and lev == 0 then
      return d
    end

    for i = 1, #D do
      local nx, ny = x + D[i][1], y + D[i][2]
      if nx >= 1 and nx <= w and ny >= 1 and ny <= h then
        local ch = g[ny]:sub(nx, nx)
        if ch == '.' then
          local nk = sk(nx, ny, lev)
          if best[nk] == nil then
            best[nk] = d + 1
            qn = qn + 1
            q[qn] = { nx, ny, lev }
          end
        end
      end
    end

    for lab, pts in pairs(portals) do
      if lab ~= 'AA' and lab ~= 'ZZ' and #pts == 2 then
        for j = 1, 2 do
          local px, py = pts[j][1], pts[j][2]
          if px == x and py == y then
            local other = pts[3 - j]
            local ox, oy = other[1], other[2]
            local outer = is_outer(x, y, w, h)
            local nlev
            if outer then
              nlev = lev - 1
            else
              nlev = lev + 1
            end
            if nlev >= 0 then
              local nk = sk(ox, oy, nlev)
              if best[nk] == nil then
                best[nk] = d + 1
                qn = qn + 1
                q[qn] = { ox, oy, nlev }
              end
            end
          end
        end
      end
    end

    do
      local aa = portals['AA']
      if aa and aa[1] then
        local ax, ay = aa[1][1], aa[1][2]
        if x == ax and y == ay and lev == 0 then
          -- start only; no extra
        end
      end
    end
  end
  return nil
end

local function day20(path)
  local lines = readLines(path)
  local g, w, h, portals = parse(lines)
  local aa = portals['AA'] and portals['AA'][1]
  local zz = portals['ZZ'] and portals['ZZ'][1]
  local p1 = bfs1(g, w, h, portals, aa, zz)
  local p2 = bfs2(g, w, h, portals, aa, zz)
  print(string.format('Part 1: %d', p1 or -1))
  print(string.format('Part 2: %d', p2 or -1))
end

return function(p)
  return day20(p)
end
