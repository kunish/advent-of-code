local function parse_input(lines)
  local elem_index = {}
  local elems = {}

  local function elem_id(name)
    if not elem_index[name] then
      elem_index[name] = #elems + 1
      elems[#elems + 1] = name
    end
    return elem_index[name]
  end

  local gen_floor = {}
  local chip_floor = {}

  for _, line in ipairs(lines) do
    local f = nil
    if line:match('^The first floor') then
      f = 0
    elseif line:match('^The second floor') then
      f = 1
    elseif line:match('^The third floor') then
      f = 2
    elseif line:match('^The fourth floor') then
      f = 3
    end
    if f ~= nil then
      for gname in line:gmatch('([%a]+) generator') do
        local e = elem_id(gname)
        gen_floor[e] = f
      end
      for cname in line:gmatch('([%a]+)%-compatible microchip') do
        local e = elem_id(cname)
        chip_floor[e] = f
      end
    end
  end

  return gen_floor, chip_floor, #elems
end

local function state_valid(gen_floor, chip_floor, n)
  for floor = 0, 3 do
    local has_other_gen = false
    for e = 1, n do
      if gen_floor[e] == floor then
        has_other_gen = true
        break
      end
    end
    for e = 1, n do
      if chip_floor[e] == floor and gen_floor[e] ~= floor then
        if has_other_gen then
          return false
        end
      end
    end
  end
  return true
end

local function all_on_top(elev, gen_floor, chip_floor, n)
  if elev ~= 3 then
    return false
  end
  for e = 1, n do
    if gen_floor[e] ~= 3 or chip_floor[e] ~= 3 then
      return false
    end
  end
  return true
end

-- Pairs (gen floor, chip floor) are unordered across elements: sort for visited dedup.
local function state_key(elev, gen_floor, chip_floor, n)
  local ps = {}
  for e = 1, n do
    ps[#ps + 1] = { gen_floor[e], chip_floor[e] }
  end
  table.sort(ps, function(a, b)
    if a[1] ~= b[1] then
      return a[1] < b[1]
    end
    return a[2] < b[2]
  end)
  local t = { elev }
  for i = 1, #ps do
    t[#t + 1] = ps[i][1]
    t[#t + 1] = ps[i][2]
  end
  return table.concat(t, ',')
end

local function min_steps(gen_floor, chip_floor, n)
  local queue = {}
  local head = 1
  local visited = {}

  local elev = 0

  local start = state_key(elev, gen_floor, chip_floor, n)
  visited[start] = true
  queue[1] = { elev = elev, gen = gen_floor, chip = chip_floor, steps = 0 }

  while head <= #queue do
    local cur = queue[head]
    head = head + 1
    if all_on_top(cur.elev, cur.gen, cur.chip, n) then
      return cur.steps
    end

    local items = {}
    for e = 1, n do
      if cur.gen[e] == cur.elev then
        items[#items + 1] = { kind = 'g', e = e }
      end
      if cur.chip[e] == cur.elev then
        items[#items + 1] = { kind = 'm', e = e }
      end
    end

    local function try_move(new_elev, pick)
      local ng = {}
      local nc = {}
      for e = 1, n do
        ng[e] = cur.gen[e]
        nc[e] = cur.chip[e]
      end
      for _, p in ipairs(pick) do
        if p.kind == 'g' then
          ng[p.e] = new_elev
        else
          nc[p.e] = new_elev
        end
      end
      if not state_valid(ng, nc, n) then
        return
      end
      local k = state_key(new_elev, ng, nc, n)
      if visited[k] then
        return
      end
      visited[k] = true
      queue[#queue + 1] = { elev = new_elev, gen = ng, chip = nc, steps = cur.steps + 1 }
    end

    for df = -1, 1, 2 do
      local ne = cur.elev + df
      if ne >= 0 and ne <= 3 then
        for i = 1, #items do
          try_move(ne, { items[i] })
        end
        for i = 1, #items do
          for j = i + 1, #items do
            try_move(ne, { items[i], items[j] })
          end
        end
      end
    end
  end
  return -1
end

local function copy_tbl(t, n)
  local o = {}
  for i = 1, n do
    o[i] = t[i]
  end
  return o
end

local function day11(path)
  local lines = readLines(path)
  local gen_floor, chip_floor, n = parse_input(lines)

  local p1 = min_steps(copy_tbl(gen_floor, n), copy_tbl(chip_floor, n), n)

  local ng = copy_tbl(gen_floor, n + 2)
  local nc = copy_tbl(chip_floor, n + 2)
  for e = n + 1, n + 2 do
    ng[e] = 0
    nc[e] = 0
  end
  local p2 = min_steps(ng, nc, n + 2)

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(path)
  return day11(path)
end
