local function parse(lines)
  local out = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local px, py, pz, vx, vy, vz = line:match('^([%-%d]+),%s*([%-%d]+),%s*([%-%d]+)%s*@%s*([%-%d]+),%s*([%-%d]+),%s*([%-%d]+)')
      out[#out + 1] = {
        px = tonumber(px),
        py = tonumber(py),
        pz = tonumber(pz),
        vx = tonumber(vx),
        vy = tonumber(vy),
        vz = tonumber(vz),
      }
    end
    i = i + 1
  end
  return out
end

local function cross2(ax, ay, bx, by)
  return ax * by - ay * bx
end

local function intersect_rays(ax, ay, avx, avy, bx, by, bvx, bvy)
  local den = cross2(avx, avy, bvx, bvy)
  if math.abs(den) < 1e-12 then
    return nil
  end
  local dx = bx - ax
  local dy = by - ay
  local t = cross2(dx, dy, bvx, bvy) / den
  local s = cross2(dx, dy, avx, avy) / den
  if t < 0 or s < 0 then
    return nil
  end
  local x = ax + t * avx
  local y = ay + t * avy
  return x, y, t, s
end

local function with_delta(h, dx, dy)
  return {
    px = h.px,
    py = h.py,
    pz = h.pz,
    vx = h.vx + dx,
    vy = h.vy + dy,
    vz = h.vz,
  }
end

local function predict_z(h, t, dz)
  return h.pz + t * (h.vz + dz)
end

local function part1(h, lo, hi)
  local n = #h
  local cnt = 0
  for i = 1, n do
    for j = i + 1, n do
      local a, b = h[i], h[j]
      local den = a.vx * b.vy - a.vy * b.vx
      if den ~= 0 then
        local dx = b.px - a.px
        local dy = b.py - a.py
        local t = (dx * b.vy - dy * b.vx) / den
        local s = (dx * a.vy - dy * a.vx) / den
        if t >= 0 and s >= 0 then
          local px = a.px + t * a.vx
          local py = a.py + t * a.vy
          if lo <= px and px <= hi and lo <= py and py <= hi then
            cnt = cnt + 1
          end
        end
      end
    end
  end
  return cnt
end

local function intersect_shifted(a, b)
  local x, y, ta, tb = intersect_rays(a.px, a.py, a.vx, a.vy, b.px, b.py, b.vx, b.vy)
  if not x then
    return nil
  end
  return { x, y, ta, tb }
end

local function part2_fixed(h)
  local tries = {
    { h[1], h[2], h[3], h[4] },
    { h[1], h[2], h[3], h[5] },
    { h[1], h[2], h[4], h[5] },
  }
  local ti = 1
  while ti <= #tries do
    local hail = tries[ti]
    local lo = -500
    local hi = 500
    local dx = lo
    while dx <= hi do
      local dy = lo
      while dy <= hi do
        local h0 = with_delta(hail[1], dx, dy)
        local p2 = intersect_shifted(with_delta(hail[2], dx, dy), h0)
        local p3 = intersect_shifted(with_delta(hail[3], dx, dy), h0)
        local p4 = intersect_shifted(with_delta(hail[4], dx, dy), h0)
        if p2 and p3 and p4 then
          local xa, ya = p2[1], p2[2]
          if math.abs(xa - p3[1]) < 1e-2 and math.abs(xa - p4[1]) < 1e-2 and math.abs(ya - p3[2]) < 1e-2 and math.abs(ya - p4[2]) < 1e-2 then
            local dz = -500
            while dz <= 500 do
              local z1 = predict_z(hail[2], p2[3], dz)
              local z2 = predict_z(hail[3], p3[3], dz)
              local z3 = predict_z(hail[4], p4[3], dz)
              if math.abs(z1 - z2) < 1 and math.abs(z2 - z3) < 1 then
                return math.floor(xa + ya + z1 + 0.5)
              end
              dz = dz + 1
            end
          end
        end
        dy = dy + 1
      end
      dx = dx + 1
    end
    ti = ti + 1
  end
  return nil
end

return function(path)
  local lines = readLines(path)
  local h = parse(lines)
  local p1 = part1(h, 200000000000000, 400000000000000)
  local p2 = part2_fixed(h)
  if not p2 then
    error('day24 part2: search failed; widen range or fix intersection')
  end
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
