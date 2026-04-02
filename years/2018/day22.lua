local function day22(path)
  local lines = readLines(path)
  local depth = tonumber((lines[1] or ''):match('depth: (%d+)')) or 0
  local tx, ty = (lines[2] or ''):match('target: (%d+),(%d+)')
  tx = tonumber(tx) or 0
  ty = tonumber(ty) or 0

  local pad = 50
  local mx = math.max(tx, ty) + pad
  local memo_ero = {}

  local function erosion(x, y)
    if x < 0 or y < 0 then
      return 0
    end
    local k = x * 65536 + y
    if memo_ero[k] then
      return memo_ero[k]
    end
    local gi
    if (x == 0 and y == 0) or (x == tx and y == ty) then
      gi = 0
    elseif y == 0 then
      gi = x * 16807
    elseif x == 0 then
      gi = y * 48271
    else
      gi = erosion(x - 1, y) * erosion(x, y - 1)
    end
    local e = (gi + depth) % 20183
    memo_ero[k] = e
    return e
  end

  local function region_type(x, y)
    return erosion(x, y) % 3
  end

  local part1 = 0
  for y = 0, ty do
    for x = 0, tx do
      part1 = part1 + region_type(x, y)
    end
  end

  -- tools: 0=torch, 1=gear, 2=neither
  local function can_use(tool, rt)
    if rt == 0 then
      return tool == 0 or tool == 1
    end
    if rt == 1 then
      return tool == 1 or tool == 2
    end
    return tool == 0 or tool == 2
  end

  local function other_tools(tool, rt)
    local t = {}
    for tt = 0, 2 do
      if tt ~= tool and can_use(tt, rt) then
        t[#t + 1] = tt
      end
    end
    return t
  end

  local heap = {}
  local function push(prio, x, y, tool)
    heap[#heap + 1] = { prio, x, y, tool }
    local i = #heap
    while i > 1 do
      local p = i // 2
      if heap[p][1] <= heap[i][1] then
        break
      end
      heap[p], heap[i] = heap[i], heap[p]
      i = p
    end
  end

  local function pop()
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
      if a <= #heap and heap[a][1] < heap[sm][1] then
        sm = a
      end
      if b <= #heap and heap[b][1] < heap[sm][1] then
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

  local function push_switches(d, x, y, tool, rt)
    local ot = other_tools(tool, rt)
    for i = 1, #ot do
      push(d + 7, x, y, ot[i])
    end
  end

  local best = {}
  local function key(x, y, t)
    return (x * 8192 + y) * 4 + t
  end

  push(0, 0, 0, 0)
  local part2 = nil
  while #heap > 0 do
    local cur = pop()
    local d, x, y, tool = cur[1], cur[2], cur[3], cur[4]
    local k = key(x, y, tool)
    if best[k] and best[k] <= d then
      goto cont
    end
    best[k] = d

    if x == tx and y == ty and tool == 0 then
      part2 = d
      break
    end

    local rt = region_type(x, y)
    push_switches(d, x, y, tool, rt)

    local dirs = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
    for di = 1, 4 do
      local nx = x + dirs[di][1]
      local ny = y + dirs[di][2]
      if nx >= 0 and ny >= 0 and nx <= mx and ny <= mx then
        local nrt = region_type(nx, ny)
        if can_use(tool, nrt) then
          push(d + 1, nx, ny, tool)
        end
      end
    end

    ::cont::
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day22(path)
end
