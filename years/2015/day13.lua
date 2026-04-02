local function parse_line(line)
  local a, _, n, b = line:match('^(%w+) would (gain) (%d+) happiness units by sitting next to (%w+)%.')
  if a then
    return a, b, tonumber(n)
  end
  a, n, b = line:match('^(%w+) would lose (%d+) happiness units by sitting next to (%w+)%.')
  if not a then
    error('bad line: ' .. line)
  end
  return a, b, -tonumber(n)
end

local function happiness(h, perm)
  local n = #perm
  local total = 0
  for i = 1, n do
    local a = perm[i]
    local left = perm[(i - 2) % n + 1]
    local right = perm[i % n + 1]
    total = total + h[a][left] + h[a][right]
  end
  return total
end

local function max_happiness(h, names)
  local perm = {}
  for i = 1, #names do
    perm[i] = names[i]
  end
  local n = #perm
  local best = -1e18
  local function permute(k)
    if k == 1 then
      local v = happiness(h, perm)
      if v > best then
        best = v
      end
      return
    end
    for i = 1, k do
      perm[k], perm[i] = perm[i], perm[k]
      permute(k - 1)
      perm[k], perm[i] = perm[i], perm[k]
    end
  end
  permute(n)
  return best
end

local function day13(path)
  local lines = readLines(path)
  local h = {}
  local seen = {}
  local people = {}
  for _, line in ipairs(lines) do
    if line ~= '' then
      local a, b, n = parse_line(line)
      if not h[a] then
        h[a] = {}
      end
      h[a][b] = n
      if not seen[a] then
        seen[a] = true
        people[#people + 1] = a
      end
      if not seen[b] then
        seen[b] = true
        people[#people + 1] = b
      end
    end
  end
  local part1 = max_happiness(h, people)
  local me = 'You'
  h[me] = {}
  for _, p in ipairs(people) do
    h[me][p] = 0
    h[p][me] = 0
  end
  people[#people + 1] = me
  local part2 = max_happiness(h, people)
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day13(path)
end
