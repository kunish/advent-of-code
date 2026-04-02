local function parse_input(lines)
  local rules = {}
  local molecule
  for _, line in ipairs(lines) do
    local a, b = line:match('^(%S+)%s*=>%s*(%S+)$')
    if a and b then
      rules[#rules + 1] = { from = a, to = b }
    elseif line:match('%S') then
      molecule = line:match('^%s*(.-)%s*$')
    end
  end
  return rules, molecule
end

local function distinct_one_step(molecule, rules)
  local seen = {}
  for _, r in ipairs(rules) do
    local from, to = r.from, r.to
    local start = 1
    while true do
      local pos = molecule:find(from, start, true)
      if not pos then
        break
      end
      local new_m = molecule:sub(1, pos - 1) .. to .. molecule:sub(pos + #from)
      seen[new_m] = true
      start = pos + 1
    end
  end
  local n = 0
  for _ in pairs(seen) do
    n = n + 1
  end
  return n
end

local function tokenize_molecule(s)
  local t = {}
  local i = 1
  while i <= #s do
    local c = s:sub(i, i)
    if c:match('%u') then
      local j = i + 1
      while j <= #s and s:sub(j, j):match('%l') do
        j = j + 1
      end
      t[#t + 1] = s:sub(i, j - 1)
      i = j
    else
      i = i + 1
    end
  end
  return t
end

local function min_steps_formula(molecule)
  local tokens = tokenize_molecule(molecule)
  local rn, ar, y = 0, 0, 0
  for _, tok in ipairs(tokens) do
    if tok == 'Rn' then
      rn = rn + 1
    elseif tok == 'Ar' then
      ar = ar + 1
    elseif tok == 'Y' then
      y = y + 1
    end
  end
  return #tokens - rn - ar - 2 * y - 1
end

local function day19(path)
  local lines = readLines(path)
  local rules, molecule = parse_input(lines)
  assert(molecule, 'missing molecule line')
  local part1 = distinct_one_step(molecule, rules)
  local part2 = min_steps_formula(molecule)
  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day19(p)
end
