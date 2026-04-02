local function skip_ws(s, pos)
  while pos <= #s do
    local ch = s:sub(pos, pos)
    if ch ~= ' ' and ch ~= '\t' and ch ~= '\n' and ch ~= '\r' then
      break
    end
    pos = pos + 1
  end
  return pos
end

local parse_any

local function parse_list(s, pos)
  assert(s:sub(pos, pos) == '[')
  pos = pos + 1
  local t = {}
  pos = skip_ws(s, pos)
  while s:sub(pos, pos) ~= ']' do
    local v
    v, pos = parse_any(s, pos)
    t[#t + 1] = v
    pos = skip_ws(s, pos)
    if s:sub(pos, pos) == ',' then
      pos = pos + 1
      pos = skip_ws(s, pos)
    end
  end
  assert(s:sub(pos, pos) == ']')
  pos = pos + 1
  return t, pos
end

parse_any = function(s, pos)
  pos = skip_ws(s, pos)
  local ch = s:sub(pos, pos)
  if ch == '[' then
    return parse_list(s, pos)
  end
  local num = s:match('^(%d+)', pos)
  assert(num)
  pos = pos + #num
  return tonumber(num), pos
end

local function cmp(left, right)
  local lt = type(left)
  local rt = type(right)
  if lt == 'number' and rt == 'number' then
    if left < right then
      return -1
    end
    if left > right then
      return 1
    end
    return 0
  end
  if lt == 'number' then
    return cmp({ left }, right)
  end
  if rt == 'number' then
    return cmp(left, { right })
  end
  local i = 1
  while true do
    local l = left[i]
    local r = right[i]
    if l == nil and r == nil then
      return 0
    end
    if l == nil then
      return -1
    end
    if r == nil then
      return 1
    end
    local c = cmp(l, r)
    if c ~= 0 then
      return c
    end
    i = i + 1
  end
end

local function day13(path)
  local lines = readLines(path)
  local packets = {}

  local pair_idx = 1
  local i = 1
  while i <= #lines do
    local a = lines[i]
    if a ~= '' then
      local b = lines[i + 1]
      local pa = select(1, parse_list(a, skip_ws(a, 1)))
      local pb = select(1, parse_list(b, skip_ws(b, 1)))
      packets[#packets + 1] = { pair_idx, pa, pb }
      i = i + 3
      pair_idx = pair_idx + 1
    else
      i = i + 1
    end
  end

  local part1 = 0
  for k = 1, #packets do
    local pr = packets[k]
    if cmp(pr[2], pr[3]) < 0 then
      part1 = part1 + pr[1]
    end
  end

  local all = {}
  for k = 1, #packets do
    local pr = packets[k]
    all[#all + 1] = pr[2]
    all[#all + 1] = pr[3]
  end

  local div2 = select(1, parse_list('[[2]]', 1))
  local div6 = select(1, parse_list('[[6]]', 1))
  all[#all + 1] = div2
  all[#all + 1] = div6

  table.sort(all, function(a, b)
    return cmp(a, b) < 0
  end)

  local p2 = 1
  local p6 = 1
  for j = 1, #all do
    if all[j] == div2 then
      p2 = j
    end
    if all[j] == div6 then
      p6 = j
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', p2 * p6))
end

return function(p)
  return day13(p)
end
