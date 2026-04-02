local function parse_seeds(line)
  local nums = {}
  for n in line:gmatch('%d+') do
    nums[#nums + 1] = tonumber(n)
  end
  return nums
end

local function parse_maps(lines)
  local maps = {}
  local cur = nil
  for i = 1, #lines do
    local line = lines[i]
    if line == '' then
      cur = nil
    elseif line:find('map:') then
      cur = {}
      maps[#maps + 1] = cur
    elseif cur then
      local a, b, c = line:match('(%d+)%s+(%d+)%s+(%d+)')
      if a then
        cur[#cur + 1] = { dst = tonumber(a), src = tonumber(b), len = tonumber(c) }
      end
    end
  end
  return maps
end

local function apply_map_ranges(segments, rules)
  local out = {}
  for si = 1, #segments do
    local seg = segments[si]
    local lo, hi = seg[1], seg[2]
    local pending = { { lo, hi } }
    for ri = 1, #rules do
      local rule = rules[ri]
      local rlo = rule.src
      local rhi = rule.src + rule.len - 1
      local off = rule.dst - rule.src
      local next_p = {}
      for pi = 1, #pending do
        local p = pending[pi]
        local a, b = p[1], p[2]
        local ilo = math.max(a, rlo)
        local ihi = math.min(b, rhi)
        if ilo <= ihi then
          out[#out + 1] = { ilo + off, ihi + off }
          if a < ilo then
            next_p[#next_p + 1] = { a, ilo - 1 }
          end
          if ihi < b then
            next_p[#next_p + 1] = { ihi + 1, b }
          end
        else
          next_p[#next_p + 1] = p
        end
      end
      pending = next_p
    end
    for pi = 1, #pending do
      out[#out + 1] = pending[pi]
    end
  end
  return out
end

local function min_range(segments)
  local m = nil
  for i = 1, #segments do
    local lo = segments[i][1]
    if m == nil or lo < m then
      m = lo
    end
  end
  return m
end

local function day5(path)
  local lines = readLines(path)
  local seeds = parse_seeds(lines[1]:match('seeds:%s*(.+)') or '')
  local maps = parse_maps(lines)

  local part1 = nil
  for si = 1, #seeds, 1 do
    local x = seeds[si]
    for mi = 1, #maps do
      local m = maps[mi]
      for ri = 1, #m do
        local r = m[ri]
        if x >= r.src and x < r.src + r.len then
          x = x - r.src + r.dst
          break
        end
      end
    end
    if part1 == nil or x < part1 then
      part1 = x
    end
  end

  local segments = {}
  for si = 1, #seeds, 2 do
    local start = seeds[si]
    local length = seeds[si + 1]
    segments[#segments + 1] = { start, start + length - 1 }
  end
  for mi = 1, #maps do
    segments = apply_map_ranges(segments, maps[mi])
  end
  local part2 = min_range(segments)

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day5(p)
end
