local function day11(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = #lines[1]
  local galaxies = {}
  for r = 1, rows do
    for c = 1, cols do
      if lines[r]:sub(c, c) == '#' then
        galaxies[#galaxies + 1] = { r = r, c = c }
      end
    end
  end

  local empty_r = {}
  for r = 1, rows do
    local empty = true
    for c = 1, cols do
      if lines[r]:sub(c, c) == '#' then
        empty = false
        break
      end
    end
    if empty then
      empty_r[r] = true
    end
  end

  local empty_c = {}
  for c = 1, cols do
    local empty = true
    for r = 1, rows do
      if lines[r]:sub(c, c) == '#' then
        empty = false
        break
      end
    end
    if empty then
      empty_c[c] = true
    end
  end

  local function dist_pair(a, b, exp)
    local extra = exp - 1
    local r0, r1 = a.r, b.r
    if r1 < r0 then
      r0, r1 = r1, r0
    end
    local dr = r1 - r0
    for r = r0 + 1, r1 - 1 do
      if empty_r[r] then
        dr = dr + extra
      end
    end
    local c0, c1 = a.c, b.c
    if c1 < c0 then
      c0, c1 = c1, c0
    end
    local dc = c1 - c0
    for c = c0 + 1, c1 - 1 do
      if empty_c[c] then
        dc = dc + extra
      end
    end
    return dr + dc
  end

  local function total(exp)
    local s = 0
    for i = 1, #galaxies do
      for j = i + 1, #galaxies do
        s = s + dist_pair(galaxies[i], galaxies[j], exp)
      end
    end
    return s
  end

  print(string.format('Part 1: %d', total(2)))
  print(string.format('Part 2: %d', total(1000000)))
end

return function(p)
  return day11(p)
end
