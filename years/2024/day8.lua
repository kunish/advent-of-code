return function(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = lines[1] and #lines[1] or 0

  local by_char = {}
  for r = 1, rows do
    for c = 1, cols do
      local ch = lines[r]:sub(c, c)
      if ch ~= '.' then
        if not by_char[ch] then
          by_char[ch] = {}
        end
        local t = by_char[ch]
        t[#t + 1] = { r, c }
      end
    end
  end

  local function in_bounds(r, c)
    return r >= 1 and r <= rows and c >= 1 and c <= cols
  end

  local function gcd(a, b)
    a = math.abs(a)
    b = math.abs(b)
    while b ~= 0 do
      a, b = b, a % b
    end
    return a
  end

  local antinodes1 = {}
  local antinodes2 = {}

  for _, pts in pairs(by_char) do
    local m = #pts
    for i = 1, m do
      for j = i + 1, m do
        local r1, c1 = pts[i][1], pts[i][2]
        local r2, c2 = pts[j][1], pts[j][2]
        -- Part 1: points at 2A-B and 2B-A
        local a1r, a1c = 2 * r1 - r2, 2 * c1 - c2
        local a2r, a2c = 2 * r2 - r1, 2 * c2 - c1
        if in_bounds(a1r, a1c) then
          antinodes1[a1r .. ',' .. a1c] = true
        end
        if in_bounds(a2r, a2c) then
          antinodes1[a2r .. ',' .. a2c] = true
        end

        -- Part 2: all collinear grid points
        local dr, dc = r2 - r1, c2 - c1
        local g = gcd(dr, dc)
        dr = dr // g
        dc = dc // g
        local r, c = r1, c1
        while in_bounds(r, c) do
          antinodes2[r .. ',' .. c] = true
          r = r - dr
          c = c - dc
        end
        r, c = r1 + dr, c1 + dc
        while in_bounds(r, c) do
          antinodes2[r .. ',' .. c] = true
          r = r + dr
          c = c + dc
        end
      end
    end
  end

  local n1, n2 = 0, 0
  for _ in pairs(antinodes1) do
    n1 = n1 + 1
  end
  for _ in pairs(antinodes2) do
    n2 = n2 + 1
  end

  print('Part 1: ' .. n1)
  print('Part 2: ' .. n2)
end
