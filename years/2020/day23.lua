return function(path)
  local line = readLines(path)[1]
  local order = {}
  local n = 0
  for d in string.gmatch(line, '%d') do
    n = n + 1
    order[n] = tonumber(d)
  end

  local function step_p1(ord, cur_pos)
    local cur = ord[cur_pos]
    local i1 = cur_pos % n + 1
    local i2 = i1 % n + 1
    local i3 = i2 % n + 1
    local c1 = ord[i1]
    local c2 = ord[i2]
    local c3 = ord[i3]
    local dest = cur - 1
    if dest < 1 then
      dest = n
    end
    while dest == c1 or dest == c2 or dest == c3 do
      dest = dest - 1
      if dest < 1 then
        dest = n
      end
    end
    local newo = {}
    local ni = 1
    local s = 1
    while s <= n do
      if s ~= i1 and s ~= i2 and s ~= i3 then
        newo[ni] = ord[s]
        ni = ni + 1
      end
      s = s + 1
    end
    local ins = 1
    while ins <= #newo and newo[ins] ~= dest do
      ins = ins + 1
    end
    local out = {}
    local oi = 1
    local j = 1
    while j <= ins do
      out[oi] = newo[j]
      oi = oi + 1
      j = j + 1
    end
    out[oi] = c1
    oi = oi + 1
    out[oi] = c2
    oi = oi + 1
    out[oi] = c3
    oi = oi + 1
    j = ins + 1
    while j <= #newo do
      out[oi] = newo[j]
      oi = oi + 1
      j = j + 1
    end
    local new_cur = 1
    while new_cur <= n do
      if out[new_cur] == cur then
        break
      end
      new_cur = new_cur + 1
    end
    new_cur = new_cur % n + 1
    return out, new_cur
  end

  local ord = {}
  local i = 1
  while i <= n do
    ord[i] = order[i]
    i = i + 1
  end
  local cur_pos = 1
  local mv = 1
  while mv <= 100 do
    ord, cur_pos = step_p1(ord, cur_pos)
    mv = mv + 1
  end

  local p1s = ''
  local idx = 1
  while idx <= n do
    if ord[idx] == 1 then
      break
    end
    idx = idx + 1
  end
  local k = 1
  while k < n do
    local pos = (idx + k - 1) % n + 1
    p1s = p1s .. tostring(ord[pos])
    k = k + 1
  end
  local part1 = p1s

  local total = 1000000
  local moves = 10000000
  local nextc = {}
  local prev = nil
  local first = nil
  for d in string.gmatch(line, '%d') do
    local v = tonumber(d)
    if not first then
      first = v
    end
    if prev then
      nextc[prev] = v
    end
    prev = v
  end
  local v = n + 1
  while v <= total do
    nextc[prev] = v
    prev = v
    v = v + 1
  end
  nextc[prev] = first

  local cur = first
  mv = 1
  while mv <= moves do
    local c1 = nextc[cur]
    local c2 = nextc[c1]
    local c3 = nextc[c2]
    local after_pick = nextc[c3]
    local dest = cur - 1
    if dest < 1 then
      dest = total
    end
    while dest == c1 or dest == c2 or dest == c3 do
      dest = dest - 1
      if dest < 1 then
        dest = total
      end
    end
    local after_dest = nextc[dest]
    nextc[cur] = after_pick
    nextc[dest] = c1
    nextc[c3] = after_dest
    cur = after_pick
    mv = mv + 1
  end

  local a = nextc[1]
  local b = nextc[a]
  local part2 = a * b

  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %d', part2))
end
