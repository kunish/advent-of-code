local function day14(path)
  local lines = readLines(path)
  local n = tonumber((lines[1] or ''):match('%d+')) or 0

  local scores = { 3, 7 }
  local e1, e2 = 0, 1

  local function step(len)
    local s = scores[e1 + 1] + scores[e2 + 1]
    if s >= 10 then
      len = len + 1
      scores[len] = math.floor(s / 10)
      len = len + 1
      scores[len] = s % 10
    else
      len = len + 1
      scores[len] = s
    end
    e1 = (e1 + 1 + scores[e1 + 1]) % len
    e2 = (e2 + 1 + scores[e2 + 1]) % len
    return len
  end

  local len = 2
  while len < n + 10 do
    len = step(len)
  end

  local part1_digits = {}
  for idx = n + 1, n + 10 do
    part1_digits[#part1_digits + 1] = tostring(scores[idx])
  end
  local part1 = table.concat(part1_digits)

  local pat_str = tostring(n)
  local plen = #pat_str
  local pattern = {}
  for p = 1, plen do
    pattern[p] = tonumber(pat_str:sub(p, p))
  end

  local cap = math.min(40000000, math.max(8192, n * 35 + 800000))
  scores = {}
  for idx = 1, cap do
    scores[idx] = 0
  end
  scores[1] = 3
  scores[2] = 7
  e1, e2 = 0, 1
  len = 2

  local function match_tail()
    if len < plen then
      return nil
    end
    local base = len - plen
    for j = 1, plen do
      if scores[base + j] ~= pattern[j] then
        return nil
      end
    end
    return base
  end

  local part2 = nil
  while part2 == nil do
    local s = scores[e1 + 1] + scores[e2 + 1]
    if s >= 10 then
      len = len + 1
      scores[len] = math.floor(s / 10)
      part2 = match_tail()
      if part2 ~= nil then
        break
      end
      len = len + 1
      scores[len] = s % 10
      part2 = match_tail()
      if part2 ~= nil then
        break
      end
    else
      len = len + 1
      scores[len] = s
      part2 = match_tail()
      if part2 ~= nil then
        break
      end
    end
    e1 = (e1 + 1 + scores[e1 + 1]) % len
    e2 = (e2 + 1 + scores[e2 + 1]) % len
  end

  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day14(path)
end
