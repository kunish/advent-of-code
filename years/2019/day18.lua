-- AoC 2019 Day 18: compressed POI graph + Dijkstra (see adamhammes gist pattern)

local function pkey(x, y)
  return x .. ',' .. y
end

local function parse_xy(pk)
  local x, y = pk:match('^(%d+),(%d+)$')
  return tonumber(x), tonumber(y)
end

local D4 = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }

local function parse_world(lines)
  local points = {}
  local keys = {}
  local doors = {}
  local entrances = {}
  for y = 1, #lines do
    local row = lines[y]
    for x = 1, #row do
      local c = row:sub(x, x)
      if c ~= '#' then
        local k = pkey(x, y)
        points[k] = true
        if c >= 'a' and c <= 'z' then
          keys[k] = c
        elseif c >= 'A' and c <= 'Z' then
          doors[k] = c
        elseif c == '@' then
          entrances[#entrances + 1] = { x, y }
        end
      end
    end
  end
  return points, keys, doors, entrances
end

local function build_pois(entrances, keys, doors)
  local pois = {}
  local idx_of = {}
  local function add(px, py)
    local pk = pkey(px, py)
    if not idx_of[pk] then
      idx_of[pk] = #pois + 1
      pois[#pois + 1] = { px, py }
    end
  end
  for i = 1, #entrances do
    add(entrances[i][1], entrances[i][2])
  end
  for pk, _ in pairs(keys) do
    local x, y = parse_xy(pk)
    add(x, y)
  end
  for pk, _ in pairs(doors) do
    local x, y = parse_xy(pk)
    add(x, y)
  end
  return pois, idx_of
end

--- BFS from POI `start_idx`; stop at other POIs (dead ends). All passages walkable.
local function compress_from(start_idx, pois, idx_of, points)
  local sx, sy = pois[start_idx][1], pois[start_idx][2]
  local sk = pkey(sx, sy)
  local q = { sk }
  local qi, qn = 1, 1
  local dist = { [sk] = 0 }
  local edges = {}
  while qi <= qn do
    local cur = q[qi]
    qi = qi + 1
    local d = dist[cur]
    local cx, cy = parse_xy(cur)
    if cur ~= sk and idx_of[cur] then
      edges[cur] = d
    else
      for i = 1, #D4 do
        local nx, ny = cx + D4[i][1], cy + D4[i][2]
        local nk = pkey(nx, ny)
        if points[nk] and dist[nk] == nil then
          dist[nk] = d + 1
          qn = qn + 1
          q[qn] = nk
        end
      end
    end
  end
  return edges
end

local function key_bit(ch)
  return 1 << (ch:byte() - string.byte('a'))
end

local function has_key_for_door(keys_mask, door_ch)
  local bit = 1 << (door_ch:byte() - string.byte('A'))
  return (keys_mask & bit) ~= 0
end

local function build_compressed(pois, idx_of, points, doors)
  local n = #pois
  local comp = {}
  for i = 1, n do
    comp[i] = {}
    local e = compress_from(i, pois, idx_of, points)
    for pk, dst in pairs(e) do
      local j = idx_of[pk]
      if j then
        comp[i][j] = dst
      end
    end
  end
  return comp
end

--- Min binary heap of { dist, ...payload }
local function heap_push(h, item)
  local n = #h + 1
  h[n] = item
  local i = n
  while i > 1 do
    local p = math.floor(i / 2)
    if h[i][1] < h[p][1] then
      h[i], h[p] = h[p], h[i]
      i = p
    else
      break
    end
  end
end

local function heap_pop(h)
  local top = h[1]
  local n = #h
  h[1] = h[n]
  h[n] = nil
  local i = 1
  while true do
    local l = i * 2
    local r = l + 1
    local sm = i
    if l <= #h and h[l][1] < h[sm][1] then
      sm = l
    end
    if r <= #h and h[r][1] < h[sm][1] then
      sm = r
    end
    if sm ~= i then
      h[i], h[sm] = h[sm], h[i]
      i = sm
    else
      break
    end
  end
  return top
end

local function all_keys_mask(keys)
  local m = 0
  for _, ch in pairs(keys) do
    m = m | key_bit(ch)
  end
  return m
end

local function solve1(comp, pois, doors, keys, start_idx, target_mask)
  local n = #pois
  local key_at = {}
  for pk, ch in pairs(keys) do
    local x, y = parse_xy(pk)
    for i = 1, n do
      if pois[i][1] == x and pois[i][2] == y then
        key_at[i] = ch
        break
      end
    end
  end

  local function dest_ok(j, keys_mask)
    local x, y = pois[j][1], pois[j][2]
    local pk = pkey(x, y)
    local dc = doors[pk]
    if dc and not has_key_for_door(keys_mask, dc) then
      return false
    end
    return true
  end

  local best = {}
  local pq = {}
  heap_push(pq, { 0, start_idx, 0 })

  while #pq > 0 do
    local cur = heap_pop(pq)
    local d, poi, km0 = cur[1], cur[2], cur[3]
    local sk = poi .. ',' .. km0
    local old = best[sk]
    if old and old <= d then
      goto cont
    end
    best[sk] = d

    local km = km0
    local kb = key_at[poi]
    if kb and (km & key_bit(kb)) == 0 then
      km = km | key_bit(kb)
    end
    if km == target_mask then
      return d
    end

    for nb, w in pairs(comp[poi]) do
      if dest_ok(nb, km) then
        heap_push(pq, { d + w, nb, km })
      end
    end
    ::cont::
  end
  return nil
end

local function solve4(comp, pois, doors, keys, starts, target_mask)
  local n = #pois
  local key_at = {}
  for pk, ch in pairs(keys) do
    local x, y = parse_xy(pk)
    for i = 1, n do
      if pois[i][1] == x and pois[i][2] == y then
        key_at[i] = ch
        break
      end
    end
  end

  local function dest_ok(j, keys_mask)
    local x, y = pois[j][1], pois[j][2]
    local pk = pkey(x, y)
    local dc = doors[pk]
    if dc and not has_key_for_door(keys_mask, dc) then
      return false
    end
    return true
  end

  local function pack4(a, b, c, d, km)
    return string.format('%d,%d,%d,%d,%d', a, b, c, d, km)
  end

  local best = {}
  local pq = {}
  heap_push(pq, { 0, starts[1], starts[2], starts[3], starts[4], 0 })

  while #pq > 0 do
    local cur = heap_pop(pq)
    local d, p1, p2, p3, p4, km0 = cur[1], cur[2], cur[3], cur[4], cur[5], cur[6]
    local sk = pack4(p1, p2, p3, p4, km0)
    local old = best[sk]
    if old and old <= d then
      goto cont
    end
    best[sk] = d

    local km = km0
    for _, pi in ipairs({ p1, p2, p3, p4 }) do
      local kb = key_at[pi]
      if kb and (km & key_bit(kb)) == 0 then
        km = km | key_bit(kb)
      end
    end
    if km == target_mask then
      return d
    end

    local pos = { p1, p2, p3, p4 }
    for ri = 1, 4 do
      local pi = pos[ri]
      for nb, w in pairs(comp[pi]) do
        if dest_ok(nb, km) then
          local n1, n2, n3, n4 = p1, p2, p3, p4
          if ri == 1 then
            n1 = nb
          elseif ri == 2 then
            n2 = nb
          elseif ri == 3 then
            n3 = nb
          else
            n4 = nb
          end
          heap_push(pq, { d + w, n1, n2, n3, n4, km })
        end
      end
    end
    ::cont::
  end
  return nil
end

local function split_entrances(lines)
  local g = {}
  for i = 1, #lines do
    g[i] = lines[i]
  end
  local ry, rx
  for y = 1, #g do
    for x = 1, #g[y] do
      if g[y]:sub(x, x) == '@' then
        ry, rx = y, x
        break
      end
    end
    if ry then
      break
    end
  end
  local pat = { '@#@', '###', '@#@' }
  for dy = -1, 1 do
    local y = ry + dy
    local mid = pat[dy + 2]
    local row = g[y]
    g[y] = row:sub(1, rx - 2) .. mid .. row:sub(rx + 2)
  end
  return g
end

local function day18(path)
  local lines = readLines(path)
  local points, keys, doors, entrances = parse_world(lines)
  local pois, idx_of = build_pois(entrances, keys, doors)
  local comp = build_compressed(pois, idx_of, points, doors)
  local tgt = all_keys_mask(keys)
  local p1 = solve1(comp, pois, doors, keys, idx_of[pkey(entrances[1][1], entrances[1][2])], tgt)

  local g2 = split_entrances(lines)
  local points2, keys2, doors2, ent2 = parse_world(g2)
  local pois2, idx2 = build_pois(ent2, keys2, doors2)
  local comp2 = build_compressed(pois2, idx2, points2, doors2)
  local tgt2 = all_keys_mask(keys2)
  local si = {}
  for i = 1, #ent2 do
    si[i] = idx2[pkey(ent2[i][1], ent2[i][2])]
  end
  local p2 = solve4(comp2, pois2, doors2, keys2, si, tgt2)

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day18(p)
end
