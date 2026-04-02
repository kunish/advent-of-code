local vowels = { a = true, e = true, i = true, o = true, u = true }
local bad = { ab = true, cd = true, pq = true, xy = true }

local function nice1(s)
  local vc = 0
  for i = 1, #s do
    if vowels[s:sub(i, i)] then
      vc = vc + 1
    end
  end
  if vc < 3 then
    return false
  end
  local double = false
  for i = 1, #s - 1 do
    if s:sub(i, i) == s:sub(i + 1, i + 1) then
      double = true
      break
    end
  end
  if not double then
    return false
  end
  for i = 1, #s - 1 do
    local pair = s:sub(i, i + 1)
    if bad[pair] then
      return false
    end
  end
  return true
end

local function nice2(s)
  local pair_twice = false
  for i = 1, #s - 3 do
    local pair = s:sub(i, i + 1)
    for j = i + 2, #s - 1 do
      if s:sub(j, j + 1) == pair then
        pair_twice = true
        break
      end
    end
    if pair_twice then
      break
    end
  end
  if not pair_twice then
    return false
  end
  for i = 1, #s - 2 do
    if s:sub(i, i) == s:sub(i + 2, i + 2) then
      return true
    end
  end
  return false
end

local function day5(path)
  local lines = readLines(path)
  local n1, n2 = 0, 0
  for _, line in ipairs(lines) do
    if nice1(line) then
      n1 = n1 + 1
    end
    if nice2(line) then
      n2 = n2 + 1
    end
  end
  print(string.format('Part 1: %d', n1))
  print(string.format('Part 2: %d', n2))
end

return function(path)
  return day5(path)
end
