local function parse_ts(line)
  local y, mo, d, h, mi = line:match('%[(%d+)%-(%d+)%-(%d+) (%d+):(%d+)%]')
  return tonumber(y), tonumber(mo), tonumber(d), tonumber(h), tonumber(mi)
end

local function cmp_log(a, b)
  local ay, amo, ad, ah, ami = parse_ts(a)
  local by, bmo, bd, bh, bmi = parse_ts(b)
  if ay ~= by then
    return ay < by
  end
  if amo ~= bmo then
    return amo < bmo
  end
  if ad ~= bd then
    return ad < bd
  end
  if ah ~= bh then
    return ah < bh
  end
  return ami < bmi
end

local function sort_lines(lines)
  local t = {}
  for i = 1, #lines do
    t[i] = lines[i]
  end
  table.sort(t, cmp_log)
  return t
end

local function day4(path)
  local lines = sort_lines(readLines(path))
  local guard_id = nil
  local sleep_start = nil
  local by_guard = {}

  for li = 1, #lines do
    local line = lines[li]
    local g = line:match('Guard #(%d+) begins shift')
    if g then
      guard_id = tonumber(g)
      if not by_guard[guard_id] then
        by_guard[guard_id] = { total = 0, mins = {} }
      end
    elseif line:find('falls asleep') then
      local _, _, _, _, smi = parse_ts(line)
      sleep_start = smi
    elseif line:find('wakes up') then
      local _, _, _, _, wmi = parse_ts(line)
      local rec = by_guard[guard_id]
      local dur = wmi - sleep_start
      rec.total = rec.total + dur
      for m = sleep_start, wmi - 1 do
        rec.mins[m] = (rec.mins[m] or 0) + 1
      end
    end
  end

  local best_g, best_total = nil, -1
  for gid, rec in pairs(by_guard) do
    if rec.total > best_total then
      best_total = rec.total
      best_g = gid
    end
  end

  local best_min, best_cnt = 0, -1
  for m, c in pairs(by_guard[best_g].mins) do
    if c > best_cnt then
      best_cnt = c
      best_min = m
    end
  end
  local part1 = best_g * best_min

  local p2g, p2m, p2c = nil, nil, -1
  for gid, rec in pairs(by_guard) do
    for m, c in pairs(rec.mins) do
      if c > p2c then
        p2c = c
        p2g = gid
        p2m = m
      end
    end
  end
  local part2 = p2g * p2m

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day4(path)
end
