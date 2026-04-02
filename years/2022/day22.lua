return function(path)
  local data = readLines(path)
  local map_lines = {}
  local instr = ''
  for i = 1, #data do
    if data[i] == '' then
      instr = data[i + 1] or ''
      break
    end
    map_lines[#map_lines + 1] = data[i]
  end

  local R = #map_lines
  local C = 0
  for i = 1, R do
    if #map_lines[i] > C then
      C = #map_lines[i]
    end
  end
  for r = 1, R do
    while #map_lines[r] < C do
      map_lines[r] = map_lines[r] .. ' '
    end
  end

  local D = { { -1, 0 }, { 0, 1 }, { 1, 0 }, { 0, -1 } }

  local CUBE = C // 3
  local REGION = { { 0, 1 }, { 0, 2 }, { 1, 1 }, { 2, 1 }, { 2, 0 }, { 3, 0 } }

  local function region_to_global(r, c, region)
    local rr, cc = REGION[region][1], REGION[region][2]
    return rr * CUBE + r, cc * CUBE + c
  end

  local function get_region(r, c)
    for i = 1, 6 do
      local rr, cc = REGION[i][1], REGION[i][2]
      if rr * CUBE <= r - 1 and r - 1 < (rr + 1) * CUBE and cc * CUBE <= c - 1 and c - 1 < (cc + 1) * CUBE then
        return i, r - 1 - rr * CUBE, c - 1 - cc * CUBE
      end
    end
    error('bad ' .. r .. ',' .. c)
  end

  local function new_coords(rr, rc, d, nd)
    local x
    if d == 1 then
      assert(rr == 0)
      x = rc
    elseif d == 2 then
      assert(rc == CUBE - 1)
      x = rr
    elseif d == 3 then
      assert(rr == CUBE - 1)
      x = CUBE - 1 - rc
    elseif d == 4 then
      assert(rc == 0)
      x = CUBE - 1 - rr
    end
    if nd == 1 then
      return CUBE - 1, x
    elseif nd == 2 then
      return x, 0
    elseif nd == 3 then
      return 0, CUBE - 1 - x
    elseif nd == 4 then
      return CUBE - 1 - x, CUBE - 1
    end
  end

  local trans = {
    [4] = { [1] = { 3, 1 }, [2] = { 2, 4 }, [3] = { 6, 4 }, [4] = { 5, 4 } },
    [1] = { [1] = { 6, 2 }, [2] = { 2, 2 }, [3] = { 3, 3 }, [4] = { 5, 2 } },
    [3] = { [1] = { 1, 1 }, [2] = { 2, 1 }, [3] = { 4, 3 }, [4] = { 5, 3 } },
    [6] = { [1] = { 5, 1 }, [2] = { 4, 1 }, [3] = { 2, 3 }, [4] = { 1, 3 } },
    [2] = { [1] = { 6, 1 }, [2] = { 4, 4 }, [3] = { 3, 4 }, [4] = { 1, 4 } },
    [5] = { [1] = { 3, 2 }, [2] = { 4, 2 }, [3] = { 6, 3 }, [4] = { 1, 2 } },
  }

  local function get_dest(r, c, d, part)
    if part == 1 then
      local rr = r
      local cc = c
      while true do
        rr = ((rr + D[d][1] - 1) % R) + 1
        cc = ((cc + D[d][2] - 1) % C) + 1
        if map_lines[rr]:sub(cc, cc) ~= ' ' then
          return rr, cc, d
        end
      end
    end

    local region, rr, rc = get_region(r, c)
    local pr = trans[region][d]
    local new_region, nd = pr[1], pr[2]
    local nr, nc = new_coords(rr, rc, d, nd)
    local gr, gc = region_to_global(nr, nc, new_region)
    local ch = map_lines[gr + 1]:sub(gc + 1, gc + 1)
    assert(ch == '.' or ch == '#')
    return gr + 1, gc + 1, nd
  end

  local function solve(part)
    local r = 1
    local c = 1
    while map_lines[r]:sub(c, c) ~= '.' do
      c = c + 1
    end
    local d = 2
    local i = 1
    while i <= #instr do
      local n = 0
      while i <= #instr and instr:sub(i, i):match('%d') do
        n = n * 10 + tonumber(instr:sub(i, i))
        i = i + 1
      end
      for _ = 1, n do
        assert(map_lines[r]:sub(c, c) == '.')
        local rr = ((r + D[d][1] - 1) % R) + 1
        local cc = ((c + D[d][2] - 1) % C) + 1
        local ch = map_lines[rr]:sub(cc, cc)
        if ch == ' ' then
          local nr, nc, nd = get_dest(r, c, d, part)
          if map_lines[nr]:sub(nc, nc) == '#' then
            break
          end
          r, c, d = nr, nc, nd
        elseif ch == '#' then
          break
        else
          r, c = rr, cc
        end
      end
      if i > #instr then
        break
      end
      local turn = instr:sub(i, i)
      if turn == 'L' then
        d = ((d + 2) % 4) + 1
      elseif turn == 'R' then
        d = (d % 4) + 1
      end
      i = i + 1
    end
    local DV = { [1] = 3, [2] = 0, [3] = 1, [4] = 2 }
    return r * 1000 + c * 4 + DV[d]
  end

  print(string.format('Part 1: %d', solve(1)))
  print(string.format('Part 2: %d', solve(2)))
end
