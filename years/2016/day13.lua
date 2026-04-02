local function popcount(n)
  local c = 0
  while n > 0 do
    c = c + (n & 1)
    n = n >> 1
  end
  return c
end

local function is_wall(x, y, fav)
  local n = x * x + 3 * x + 2 * x * y + y + y * y + fav
  return (popcount(n) & 1) == 1
end

local function day13(path)
  local lines = readLines(path)
  local fav = tonumber((lines[1] or '0'):match('%d+')) or 0

  local function key(x, y)
    return x * 65536 + y
  end

  -- Part 1: shortest path to (31,39)
  do
    local q = {}
    local head = 1
    local seen = {}
    q[1] = { 1, 1, 0 }
    seen[key(1, 1)] = true
    local p1 = nil
    while head <= #q do
      local x, y, d = table.unpack(q[head])
      head = head + 1
      if x == 31 and y == 39 then
        p1 = d
        break
      end
      for _, dir in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nx, ny = x + dir[1], y + dir[2]
        if nx >= 0 and ny >= 0 and not is_wall(nx, ny, fav) then
          local k = key(nx, ny)
          if not seen[k] then
            seen[k] = true
            q[#q + 1] = { nx, ny, d + 1 }
          end
        end
      end
    end
    print(string.format('Part 1: %d', p1 or -1))
  end

  -- Part 2: locations reachable in at most 50 steps
  do
    local q = {}
    local head = 1
    local seen = {}
    q[1] = { 1, 1, 0 }
    seen[key(1, 1)] = true
    local within = 0
    while head <= #q do
      local x, y, d = table.unpack(q[head])
      head = head + 1
      within = within + 1
      if d == 50 then
        -- do not expand further
      else
        for _, dir in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
          local nx, ny = x + dir[1], y + dir[2]
          if nx >= 0 and ny >= 0 and not is_wall(nx, ny, fav) then
            local k = key(nx, ny)
            if not seen[k] then
              seen[k] = true
              q[#q + 1] = { nx, ny, d + 1 }
            end
          end
        end
      end
    end
    print(string.format('Part 2: %d', within))
  end
end

return function(path)
  return day13(path)
end
