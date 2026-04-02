local function sorted_letters(w)
  local t = {}
  for i = 1, #w do
    t[i] = w:sub(i, i)
  end
  table.sort(t)
  return table.concat(t)
end

local function valid1(words)
  local seen = {}
  for _, w in ipairs(words) do
    if seen[w] then
      return false
    end
    seen[w] = true
  end
  return true
end

local function valid2(words)
  local seen = {}
  for _, w in ipairs(words) do
    local sig = sorted_letters(w)
    if seen[sig] then
      return false
    end
    seen[sig] = true
  end
  return true
end

local function split_words(line)
  local words = {}
  for w in line:gmatch('%S+') do
    words[#words + 1] = w
  end
  return words
end

local function day4(path)
  local lines = readLines(path)
  local part1, part2 = 0, 0
  for _, line in ipairs(lines) do
    if line ~= '' then
      local words = split_words(line)
      if valid1(words) then
        part1 = part1 + 1
      end
      if valid2(words) then
        part2 = part2 + 1
      end
    end
  end
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day4(path)
end
