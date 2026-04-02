return function(path)
  local jet = readLines(path)[1]
  local jl = #jet

  local rocks = {
    { { 0, 0 }, { 1, 0 }, { 2, 0 }, { 3, 0 } },
    { { 1, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 1, 2 } },
    { { 0, 0 }, { 1, 0 }, { 2, 0 }, { 2, 1 }, { 2, 2 } },
    { { 0, 0 }, { 0, 1 }, { 0, 2 }, { 0, 3 } },
    { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } },
  }

  local function rock_width(cells)
    local mx = 0
    for i = 1, #cells do
      if cells[i][1] > mx then
        mx = cells[i][1]
      end
    end
    return mx + 1
  end

  local function rock_height(cells)
    local mx = 0
    for i = 1, #cells do
      if cells[i][2] > mx then
        mx = cells[i][2]
      end
    end
    return mx + 1
  end

  local function collides(occupied, ox, oy, cells)
    for i = 1, #cells do
      local x = ox + cells[i][1]
      local y = oy + cells[i][2]
      if x < 0 or x > 6 or y < 0 then
        return true
      end
      if occupied[x .. ',' .. y] then
        return true
      end
    end
    return false
  end

  local function simulate(max_rocks, stop_at_seen)
    local occupied = {}
    local max_y = -1
    local ji = 0
    local seen = {}
    local ri = 0
    local n = 0

    local function fingerprint()
      local rows = {}
      local ylo = max_y - 25
      if ylo < 0 then
        ylo = 0
      end
      local yy = ylo
      while yy <= max_y do
        local bits = 0
        for xx = 0, 6 do
          if occupied[xx .. ',' .. yy] then
            bits = bits | (1 << xx)
          end
        end
        rows[#rows + 1] = tostring(bits)
        yy = yy + 1
      end
      return table.concat(rows, ',')
    end

    while n < max_rocks do
      local cells = rocks[(ri % 5) + 1]
      local ox = 2
      local oy = max_y + 4
      ri = ri + 1

      while true do
        ji = ji + 1
        local jch = jet:sub((ji - 1) % jl + 1, (ji - 1) % jl + 1)
        local push = jch == '>' and 1 or -1
        if not collides(occupied, ox + push, oy, cells) then
          ox = ox + push
        end
        if collides(occupied, ox, oy - 1, cells) then
          break
        end
        oy = oy - 1
      end

      for i = 1, #cells do
        local x = ox + cells[i][1]
        local y = oy + cells[i][2]
        occupied[x .. ',' .. y] = true
        if y > max_y then
          max_y = y
        end
      end

      n = n + 1
      if stop_at_seen then
        local key = string.format('%d|%d|%s', (ri - 1) % 5, ji % jl, fingerprint())
        local prev = seen[key]
        if prev then
          return {
            n = n,
            height = max_y + 1,
            cycle_start_n = prev.n,
            cycle_start_h = prev.height,
            cycle_len = n - prev.n,
            cycle_dh = (max_y + 1) - prev.height,
          }
        end
        seen[key] = { n = n, height = max_y + 1 }
      end
    end
    return { n = n, height = max_y + 1 }
  end

  local p1 = simulate(2022, false)
  print(string.format('Part 1: %d', p1.height))

  local target = 1000000000000
  local c = simulate(100000, true)
  if not c.cycle_len then
    local p2 = simulate(target, false)
    print(string.format('Part 2: %d', p2.height))
    return
  end

  local n1 = c.cycle_start_n
  local h1 = c.cycle_start_h
  local clen = c.cycle_len
  local dh = c.cycle_dh

  local rem = target - n1
  local q = math.floor(rem / clen)
  local r = rem % clen

  local h_n1r = simulate(n1 + r, false).height
  local part2 = h1 + q * dh + (h_n1r - h1)

  print(string.format('Part 2: %d', part2))
end
