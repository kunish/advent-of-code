local function parse_brick(line)
  local x1, y1, z1, x2, y2, z2 = line:match('^(%d+),(%d+),(%d+)~(%d+),(%d+),(%d+)$')
  x1, y1, z1, x2, y2, z2 = tonumber(x1), tonumber(y1), tonumber(z1), tonumber(x2), tonumber(y2), tonumber(z2)
  if x1 > x2 then
    x1, x2 = x2, x1
  end
  if y1 > y2 then
    y1, y2 = y2, y1
  end
  if z1 > z2 then
    z1, z2 = z2, z1
  end
  return { x1 = x1, y1 = y1, z1 = z1, x2 = x2, y2 = y2, z2 = z2, id = 0 }
end

local function overlaps_xy(a, b)
  return not (a.x2 < b.x1 or b.x2 < a.x1 or a.y2 < b.y1 or b.y2 < a.y1)
end

local function settle(bricks)
  table.sort(bricks, function(a, b)
    return a.z1 < b.z1
  end)
  local bi = 1
  while bi <= #bricks do
    local b = bricks[bi]
    local max_z = 1
    local bj = 1
    while bj < bi do
      local o = bricks[bj]
      if overlaps_xy(b, o) then
        if o.z2 + 1 > max_z then
          max_z = o.z2 + 1
        end
      end
      bj = bj + 1
    end
    local dz = b.z1 - max_z
    b.z1 = b.z1 - dz
    b.z2 = b.z2 - dz
    bi = bi + 1
  end
  table.sort(bricks, function(a, b)
    if a.z1 ~= b.z1 then
      return a.z1 < b.z1
    end
    return a.x1 < b.x1
  end)
  bi = 1
  while bi <= #bricks do
    bricks[bi].id = bi
    bi = bi + 1
  end
end

local function build_support(bricks)
  local supports = {}
  local supported_by = {}
  local bi = 1
  while bi <= #bricks do
    supports[bi] = {}
    supported_by[bi] = {}
    bi = bi + 1
  end
  local hi = 1
  while hi <= #bricks do
    local b = bricks[hi]
    local lo = 1
    while lo < hi do
      local o = bricks[lo]
      if b.z1 == o.z2 + 1 and overlaps_xy(b, o) then
        supports[lo][#supports[lo] + 1] = hi
        supported_by[hi][#supported_by[hi] + 1] = lo
      end
      lo = lo + 1
    end
    hi = hi + 1
  end
  return supports, supported_by
end

return function(path)
  local lines = readLines(path)
  local bricks = {}
  local li = 1
  while li <= #lines do
    if lines[li] ~= '' then
      bricks[#bricks + 1] = parse_brick(lines[li])
    end
    li = li + 1
  end
  settle(bricks)
  local supports, supported_by = build_support(bricks)

  local p1 = 0
  local p2 = 0
  local bi = 1
  while bi <= #bricks do
    local unsafe = false
    local wj = 1
    while wj <= #supports[bi] do
      local j = supports[bi][wj]
      if #supported_by[j] == 1 then
        unsafe = true
        break
      end
      wj = wj + 1
    end
    if not unsafe then
      p1 = p1 + 1
    end

    local falling = {}
    local q = {}
    local qh, qt = 1, 1
    local fj = 1
    while fj <= #supports[bi] do
      local j = supports[bi][fj]
      if #supported_by[j] == 1 then
        falling[j] = true
        q[qt] = j
        qt = qt + 1
      end
      fj = fj + 1
    end
    while qh < qt do
      local cur = q[qh]
      qh = qh + 1
      local fk = 1
      while fk <= #supports[cur] do
        local j = supports[cur][fk]
        if not falling[j] then
          local cnt = 0
          local sk = 1
          while sk <= #supported_by[j] do
            local sb = supported_by[j][sk]
            if not falling[sb] then
              cnt = cnt + 1
            end
            sk = sk + 1
          end
          if cnt == 0 then
            falling[j] = true
            q[qt] = j
            qt = qt + 1
          end
        end
        fk = fk + 1
      end
    end
    falling[bi] = nil
    local chain = 0
    for _ in pairs(falling) do
      chain = chain + 1
    end
    p2 = p2 + chain

    bi = bi + 1
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
