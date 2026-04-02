local function parse_bots(lines)
  local bots = {}
  for i = 1, #lines do
    local x, y, z, r = lines[i]:match('pos=<(%-?%d+),(%-?%d+),(%-?%d+)>, r=(%d+)')
    if x then
      bots[#bots + 1] = { x = tonumber(x), y = tonumber(y), z = tonumber(z), r = tonumber(r) }
    end
  end
  return bots
end

local function dist_point_to_box(px, py, pz, x1, y1, z1, x2, y2, z2)
  local qx = math.max(x1, math.min(px, x2))
  local qy = math.max(y1, math.min(py, y2))
  local qz = math.max(z1, math.min(pz, z2))
  return math.abs(px - qx) + math.abs(py - qy) + math.abs(pz - qz)
end

local function dist_origin_to_box(x1, y1, z1, x2, y2, z2)
  local function axis(a1, a2)
    if a1 <= 0 and a2 >= 0 then
      return 0
    end
    if a2 < 0 then
      return -a2
    end
    return a1
  end
  return axis(x1, x2) + axis(y1, y2) + axis(z1, z2)
end

local function max_bots_reachable(bots, x1, y1, z1, x2, y2, z2)
  local n = 0
  for i = 1, #bots do
    local b = bots[i]
    if dist_point_to_box(b.x, b.y, b.z, x1, y1, z1, x2, y2, z2) <= b.r then
      n = n + 1
    end
  end
  return n
end

local function count_at(bots, x, y, z)
  local n = 0
  for i = 1, #bots do
    local b = bots[i]
    if math.abs(b.x - x) + math.abs(b.y - y) + math.abs(b.z - z) <= b.r then
      n = n + 1
    end
  end
  return n
end

local function heap_push(heap, el)
  heap[#heap + 1] = el
  local i = #heap
  while i > 1 do
    local p = i // 2
    if heap[p].prio <= heap[i].prio then
      break
    end
    heap[p], heap[i] = heap[i], heap[p]
    i = p
  end
end

local function heap_pop(heap)
  if #heap == 0 then
    return nil
  end
  local r = heap[1]
  heap[1] = heap[#heap]
  heap[#heap] = nil
  local i = 1
  while true do
    local a = i * 2
    local b = a + 1
    local sm = i
    if a <= #heap and heap[a].prio < heap[sm].prio then
      sm = a
    end
    if b <= #heap and heap[b].prio < heap[sm].prio then
      sm = b
    end
    if sm == i then
      break
    end
    heap[i], heap[sm] = heap[sm], heap[i]
    i = sm
  end
  return r
end

local function day23(path)
  local lines = readLines(path)
  local bots = parse_bots(lines)

  local bestb = bots[1]
  for i = 2, #bots do
    if bots[i].r > bestb.r then
      bestb = bots[i]
    end
  end

  local part1 = 0
  for i = 1, #bots do
    local b = bots[i]
    if math.abs(b.x - bestb.x) + math.abs(b.y - bestb.y) + math.abs(b.z - bestb.z) <= bestb.r then
      part1 = part1 + 1
    end
  end

  local minx, maxx = math.huge, -math.huge
  local miny, maxy = math.huge, -math.huge
  local minz, maxz = math.huge, -math.huge
  for i = 1, #bots do
    local b = bots[i]
    minx = math.min(minx, b.x - b.r)
    maxx = math.max(maxx, b.x + b.r)
    miny = math.min(miny, b.y - b.r)
    maxy = math.max(maxy, b.y + b.r)
    minz = math.min(minz, b.z - b.r)
    maxz = math.max(maxz, b.z + b.r)
  end

  local heap = {}
  local function push_box(x1, y1, z1, x2, y2, z2)
    local ub = max_bots_reachable(bots, x1, y1, z1, x2, y2, z2)
    local d0 = dist_origin_to_box(x1, y1, z1, x2, y2, z2)
    local sx = x2 - x1 + 1
    local sy = y2 - y1 + 1
    local sz = z2 - z1 + 1
    local size = math.max(sx, sy, sz)
    local prio = -ub * 1000000000000 + d0
    heap_push(heap, {
      prio = prio,
      ub = ub,
      d0 = d0,
      x1 = x1,
      y1 = y1,
      z1 = z1,
      x2 = x2,
      y2 = y2,
      z2 = z2,
    })
  end

  push_box(minx, miny, minz, maxx, maxy, maxz)

  local best_cnt = -1
  local best_dist = nil

  while #heap > 0 do
    local cur = heap_pop(heap)
    local ub, d0 = cur.ub, cur.d0
    local x1, y1, z1, x2, y2, z2 = cur.x1, cur.y1, cur.z1, cur.x2, cur.y2, cur.z2

    if best_cnt >= 0 and ub < best_cnt then
      goto cont
    end

    if x1 == x2 and y1 == y2 and z1 == z2 then
      local c = count_at(bots, x1, y1, z1)
      local dd = math.abs(x1) + math.abs(y1) + math.abs(z1)
      if c > best_cnt or (c == best_cnt and (best_dist == nil or dd < best_dist)) then
        best_cnt = c
        best_dist = dd
      end
      goto cont
    end

    local mx = (x1 + x2) // 2
    local my = (y1 + y2) // 2
    local mz = (z1 + z2) // 2

    local subs = {
      { x1, y1, z1, mx, my, mz },
      { mx + 1, y1, z1, x2, my, mz },
      { x1, my + 1, z1, mx, y2, mz },
      { mx + 1, my + 1, z1, x2, y2, mz },
      { x1, y1, mz + 1, mx, my, z2 },
      { mx + 1, y1, mz + 1, x2, my, z2 },
      { x1, my + 1, mz + 1, mx, y2, z2 },
      { mx + 1, my + 1, mz + 1, x2, y2, z2 },
    }
    for si = 1, 8 do
      local s = subs[si]
      local ax1, ay1, az1, ax2, ay2, az2 = s[1], s[2], s[3], s[4], s[5], s[6]
      if ax1 <= ax2 and ay1 <= ay2 and az1 <= az2 then
        push_box(ax1, ay1, az1, ax2, ay2, az2)
      end
    end

    ::cont::
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', best_dist))
end

return function(path)
  return day23(path)
end
