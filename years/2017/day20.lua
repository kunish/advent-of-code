local function parse_tri(s)
  local x, y, z = s:match('([^,]+),([^,]+),([^,]+)')
  return { tonumber(x), tonumber(y), tonumber(z) }
end

local function manhattan(v)
  return math.abs(v[1]) + math.abs(v[2]) + math.abs(v[3])
end

local function day20(path)
  local lines = readLines(path)
  local parts = {}
  for i, line in ipairs(lines) do
    local ps, vs, as = line:match('p=<([^>]+)>'), line:match('v=<([^>]+)>'), line:match('a=<([^>]+)>')
    if ps then
      parts[#parts + 1] = {
        p = parse_tri(ps),
        v = parse_tri(vs),
        a = parse_tri(as),
        id = i,
      }
    end
  end

  table.sort(parts, function(x, y)
    local ma, mb = manhattan(x.a), manhattan(y.a)
    if ma ~= mb then
      return ma < mb
    end
    ma, mb = manhattan(x.v), manhattan(y.v)
    if ma ~= mb then
      return ma < mb
    end
    return manhattan(x.p) < manhattan(y.p)
  end)

  local best = parts[1].id - 1

  local alive = {}
  for i = 1, #parts do
    alive[i] = {
      p = { parts[i].p[1], parts[i].p[2], parts[i].p[3] },
      v = { parts[i].v[1], parts[i].v[2], parts[i].v[3] },
      a = { parts[i].a[1], parts[i].a[2], parts[i].a[3] },
    }
  end

  for _ = 1, 1000 do
    local pos_map = {}
    for i, pr in ipairs(alive) do
      if pr then
        pr.v[1] = pr.v[1] + pr.a[1]
        pr.v[2] = pr.v[2] + pr.a[2]
        pr.v[3] = pr.v[3] + pr.a[3]
        pr.p[1] = pr.p[1] + pr.v[1]
        pr.p[2] = pr.p[2] + pr.v[2]
        pr.p[3] = pr.p[3] + pr.v[3]
        local k = string.format('%d,%d,%d', pr.p[1], pr.p[2], pr.p[3])
        pos_map[k] = (pos_map[k] or 0) + 1
      end
    end
    for i, pr in ipairs(alive) do
      if pr then
        local k = string.format('%d,%d,%d', pr.p[1], pr.p[2], pr.p[3])
        if pos_map[k] > 1 then
          alive[i] = false
        end
      end
    end
  end

  local remaining = 0
  for _, pr in ipairs(alive) do
    if pr then
      remaining = remaining + 1
    end
  end

  print(string.format('Part 1: %d', best))
  print(string.format('Part 2: %d', remaining))
end

return function(path)
  return day20(path)
end
