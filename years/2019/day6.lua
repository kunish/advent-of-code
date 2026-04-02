local function parse_orbits(lines)
  local orb = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    local a, b = line:match('([^)]+)%)%s*(.+)')
    if a and b then
      orb[b] = a
    end
    i = i + 1
  end
  return orb
end

local function depth(orb, name)
  local d = 0
  local cur = name
  while orb[cur] do
    d = d + 1
    cur = orb[cur]
  end
  return d
end

local function path_to_root(orb, name)
  local t = {}
  local cur = name
  while cur do
    t[#t + 1] = cur
    cur = orb[cur]
  end
  return t
end

local function day6(path)
  local lines = readLines(path)
  local orb = parse_orbits(lines)

  local part1 = 0
  for body, _ in pairs(orb) do
    part1 = part1 + depth(orb, body)
  end

  local pyou = path_to_root(orb, orb['YOU'])
  local psan = path_to_root(orb, orb['SAN'])
  local iu, isan = #pyou, #psan
  while iu > 0 and isan > 0 and pyou[iu] == psan[isan] do
    iu = iu - 1
    isan = isan - 1
  end
  local part2 = iu + isan

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day6(path)
end
