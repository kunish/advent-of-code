return function(path)
  local lines = readLines(path)
  local sensors = {}
  local beacons_on_row = {}

  local row_target = 2000000
  local limit = 4000000

  for i = 1, #lines do
    local line = lines[i]
    local sx, sy, bx, by = line:match(
      'Sensor at x=(-?%d+), y=(-?%d+): closest beacon is at x=(-?%d+), y=(-?%d+)'
    )
    sx, sy, bx, by = tonumber(sx), tonumber(sy), tonumber(bx), tonumber(by)
    sensors[#sensors + 1] = { sx, sy, math.abs(sx - bx) + math.abs(sy - by) }
    if by == row_target then
      beacons_on_row[bx] = true
    end
  end

  local function merge_intervals(iv)
    if #iv == 0 then
      return {}
    end
    table.sort(iv, function(a, b)
      return a[1] < b[1]
    end)
    local out = { { iv[1][1], iv[1][2] } }
    local oi = 1
    local ii = 2
    while ii <= #iv do
      local lo, hi = iv[ii][1], iv[ii][2]
      if lo <= out[oi][2] + 1 then
        if hi > out[oi][2] then
          out[oi][2] = hi
        end
      else
        oi = oi + 1
        out[oi] = { lo, hi }
      end
      ii = ii + 1
    end
    return out
  end

  local function intervals_for_row(y)
    local iv = {}
    for si = 1, #sensors do
      local sx, sy, d = sensors[si][1], sensors[si][2], sensors[si][3]
      local dy = math.abs(y - sy)
      if dy <= d then
        local rem = d - dy
        iv[#iv + 1] = { sx - rem, sx + rem }
      end
    end
    return merge_intervals(iv)
  end

  local iv_row = intervals_for_row(row_target)
  local part1 = 0
  for ii = 1, #iv_row do
    part1 = part1 + (iv_row[ii][2] - iv_row[ii][1] + 1)
  end
  for bx, _ in pairs(beacons_on_row) do
    for ii = 1, #iv_row do
      if bx >= iv_row[ii][1] and bx <= iv_row[ii][2] then
        part1 = part1 - 1
        break
      end
    end
  end

  print(string.format('Part 1: %d', part1))

  local function intervals_clipped(y)
    local raw = {}
    for si = 1, #sensors do
      local sx, sy, d = sensors[si][1], sensors[si][2], sensors[si][3]
      local dy = math.abs(y - sy)
      if dy <= d then
        local rem = d - dy
        local lo = sx - rem
        local hi = sx + rem
        if hi >= 0 and lo <= limit then
          local lo2 = math.max(lo, 0)
          local hi2 = math.min(hi, limit)
          if lo2 <= hi2 then
            raw[#raw + 1] = { lo2, hi2 }
          end
        end
      end
    end
    return merge_intervals(raw)
  end

  local part2x, part2y = nil, nil
  local y = 0
  while y <= limit do
    local iv = intervals_clipped(y)
    local prev_hi = -1
    for ii = 1, #iv do
      local lo, hi = iv[ii][1], iv[ii][2]
      if lo > prev_hi + 1 then
        local gx = prev_hi + 1
        if gx >= 0 and gx <= limit then
          part2x, part2y = gx, y
          break
        end
      end
      if hi > prev_hi then
        prev_hi = hi
      end
    end
    if part2x then
      break
    end
    if prev_hi < limit then
      part2x, part2y = prev_hi + 1, y
      break
    end
    y = y + 1
  end

  local part2 = part2x * 4000000 + part2y
  print(string.format('Part 2: %d', part2))
end
