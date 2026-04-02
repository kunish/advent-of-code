local function to_bytes(s)
  local t = {}
  for i = 1, #s do
    t[i] = string.byte(s:sub(i, i))
  end
  return t
end

local function from_bytes(t)
  local parts = {}
  for i = 1, #t do
    parts[i] = string.char(t[i])
  end
  return table.concat(parts)
end

local function increment(t)
  local i = #t
  while i >= 1 do
    if t[i] >= string.byte('z') then
      t[i] = string.byte('a')
      i = i - 1
    else
      t[i] = t[i] + 1
      if t[i] == string.byte('i') or t[i] == string.byte('o') or t[i] == string.byte('l') then
        t[i] = t[i] + 1
      end
      if t[i] > string.byte('z') then
        t[i] = string.byte('a')
        i = i - 1
      else
        for j = i + 1, #t do
          t[j] = string.byte('a')
        end
        return
      end
    end
  end
end

local function has_straight(t)
  for i = 1, #t - 2 do
    if t[i] + 1 == t[i + 1] and t[i + 1] + 1 == t[i + 2] then
      return true
    end
  end
  return false
end

local function has_two_pairs(s)
  for i = 1, #s - 1 do
    if s:sub(i, i) == s:sub(i + 1, i + 1) then
      for j = i + 2, #s - 1 do
        if s:sub(j, j) == s:sub(j + 1, j + 1) then
          return true
        end
      end
    end
  end
  return false
end

local function valid(s)
  if s:find('[iol]') then
    return false
  end
  local t = to_bytes(s)
  if not has_straight(t) then
    return false
  end
  if not has_two_pairs(s) then
    return false
  end
  return true
end

local function next_password(t)
  while true do
    increment(t)
    local s = from_bytes(t)
    if valid(s) then
      return s
    end
  end
end

local function day11(path)
  local lines = readLines(path)
  local start = (lines[1] or ''):gsub('%s+', '')
  local t = to_bytes(start)
  local part1 = next_password(t)
  local t2 = to_bytes(part1)
  local part2 = next_password(t2)
  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %s', part2))
end

return function(path)
  return day11(path)
end
