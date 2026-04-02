local function parse_part(line)
  local x = tonumber(line:match('x=(%d+)'))
  local m = tonumber(line:match('m=(%d+)'))
  local a = tonumber(line:match('a=(%d+)'))
  local s = tonumber(line:match('s=(%d+)'))
  return { x = x, m = m, a = a, s = s }
end

local function parse_workflow(line)
  local name, body = line:match('^(%w+)%{(.*)%}$')
  local rules = {}
  local start = 1
  local i = 1
  local n = #body
  while i <= n do
    if body:sub(i, i) == ',' or i == n then
      local seg_end = i
      if body:sub(i, i) == ',' then
        seg_end = i - 1
      end
      local chunk = body:sub(start, seg_end)
      local field, op, num, tgt = chunk:match('^([xmas])([<>])(%d+):(%w+)$')
      if field then
        rules[#rules + 1] = { kind = 'cond', field = field, op = op, num = tonumber(num), target = tgt }
      else
        rules[#rules + 1] = { kind = 'jump', target = chunk }
      end
      start = i + 1
    end
    i = i + 1
  end
  return name, rules
end

local function get_field(part, f)
  if f == 'x' then
    return part.x
  end
  if f == 'm' then
    return part.m
  end
  if f == 'a' then
    return part.a
  end
  return part.s
end

local function apply_part(wfs, part)
  local wf = 'in'
  while true do
    if wf == 'A' then
      return true
    end
    if wf == 'R' then
      return false
    end
    local rules = wfs[wf]
    local ri = 1
    while ri <= #rules do
      local r = rules[ri]
      if r.kind == 'cond' then
        local v = get_field(part, r.field)
        local ok
        if r.op == '<' then
          ok = v < r.num
        else
          ok = v > r.num
        end
        if ok then
          wf = r.target
          break
        end
      else
        wf = r.target
        break
      end
      ri = ri + 1
    end
  end
end

local function copy_ranges(r)
  return {
    x = { r.x[1], r.x[2] },
    m = { r.m[1], r.m[2] },
    a = { r.a[1], r.a[2] },
    s = { r.s[1], r.s[2] },
  }
end

local function range_volume(r)
  local function len(a)
    return math.max(0, a[2] - a[1] + 1)
  end
  return len(r.x) * len(r.m) * len(r.a) * len(r.s)
end

local function split_range(r, field, op, num)
  local rr = copy_ranges(r)
  local pass = copy_ranges(r)
  local f = rr[field]
  if op == '<' then
    -- pass: x < num  => [lo, num-1]
    pass[field] = { f[1], math.min(f[2], num - 1) }
    rr[field] = { math.max(f[1], num), f[2] }
  else
    -- x > num
    pass[field] = { math.max(f[1], num + 1), f[2] }
    rr[field] = { f[1], math.min(f[2], num) }
  end
  if pass[field][1] > pass[field][2] then
    pass = nil
  end
  if rr[field][1] > rr[field][2] then
    rr = nil
  end
  return pass, rr
end

local function count_accepted(wfs, wf_name, ranges)
  if wf_name == 'A' then
    return range_volume(ranges)
  end
  if wf_name == 'R' then
    return 0
  end
  local rules = wfs[wf_name]
  local total = 0
  local rem = copy_ranges(ranges)
  local ri = 1
  while ri <= #rules do
    local r = rules[ri]
    if r.kind == 'cond' then
      local pass, fail = split_range(rem, r.field, r.op, r.num)
      if pass then
        total = total + count_accepted(wfs, r.target, pass)
      end
      rem = fail
      if not rem then
        break
      end
    else
      total = total + count_accepted(wfs, r.target, rem)
      break
    end
    ri = ri + 1
  end
  return total
end

return function(path)
  local lines = readLines(path)
  local wfs = {}
  local li = 1
  while li <= #lines do
    local line = lines[li]
    if line == '' then
      break
    end
    local name, rules = parse_workflow(line)
    wfs[name] = rules
    li = li + 1
  end

  local p1 = 0
  li = li + 1
  while li <= #lines do
    local line = lines[li]
    if line ~= '' then
      local part = parse_part(line)
      if apply_part(wfs, part) then
        p1 = p1 + part.x + part.m + part.a + part.s
      end
    end
    li = li + 1
  end

  local full = {
    x = { 1, 4000 },
    m = { 1, 4000 },
    a = { 1, 4000 },
    s = { 1, 4000 },
  }
  local p2 = count_accepted(wfs, 'in', full)

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
