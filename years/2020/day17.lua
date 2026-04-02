return function(path)
  local lines = readLines(path)
  local active3 = {}
  local y = 1
  while y <= #lines do
    local line = lines[y]
    local x = 1
    while x <= #line do
      if string.sub(line, x, x) == '#' then
        active3[x .. ',' .. y .. ',0'] = true
      end
      x = x + 1
    end
    y = y + 1
  end

  local function neighbors3(k)
    local px, py, pz = string.match(k, '([^,]+),([^,]+),([^,]+)')
    local ox = tonumber(px)
    local oy = tonumber(py)
    local oz = tonumber(pz)
    local out = {}
    local n = 0
    local dx = -1
    while dx <= 1 do
      local dy = -1
      while dy <= 1 do
        local dz = -1
        while dz <= 1 do
          if dx ~= 0 or dy ~= 0 or dz ~= 0 then
            n = n + 1
            out[n] = (ox + dx) .. ',' .. (oy + dy) .. ',' .. (oz + dz)
          end
          dz = dz + 1
        end
        dy = dy + 1
      end
      dx = dx + 1
    end
    return out, n
  end

  local cur = active3
  local cycle = 1
  while cycle <= 6 do
    local counts = {}
    for k, _ in pairs(cur) do
      local nbrs, nn = neighbors3(k)
      local i = 1
      while i <= nn do
        local nk = nbrs[i]
        counts[nk] = (counts[nk] or 0) + 1
        i = i + 1
      end
    end
    local nxt = {}
    for k, c in pairs(counts) do
      local was = cur[k]
      if was and (c == 2 or c == 3) then
        nxt[k] = true
      elseif not was and c == 3 then
        nxt[k] = true
      end
    end
    cur = nxt
    cycle = cycle + 1
  end

  local p1 = 0
  for _ in pairs(cur) do
    p1 = p1 + 1
  end

  local active4 = {}
  y = 1
  while y <= #lines do
    local line = lines[y]
    local x = 1
    while x <= #line do
      if string.sub(line, x, x) == '#' then
        active4[x .. ',' .. y .. ',0,0'] = true
      end
      x = x + 1
    end
    y = y + 1
  end

  local function neighbors4(k)
    local px, py, pz, pw = string.match(k, '([^,]+),([^,]+),([^,]+),([^,]+)')
    local ox = tonumber(px)
    local oy = tonumber(py)
    local oz = tonumber(pz)
    local ow = tonumber(pw)
    local out = {}
    local n = 0
    local dx = -1
    while dx <= 1 do
      local dy = -1
      while dy <= 1 do
        local dz = -1
        while dz <= 1 do
          local dw = -1
          while dw <= 1 do
            if dx ~= 0 or dy ~= 0 or dz ~= 0 or dw ~= 0 then
              n = n + 1
              out[n] = (ox + dx) .. ',' .. (oy + dy) .. ',' .. (oz + dz) .. ',' .. (ow + dw)
            end
            dw = dw + 1
          end
          dz = dz + 1
        end
        dy = dy + 1
      end
      dx = dx + 1
    end
    return out, n
  end

  cur = active4
  cycle = 1
  while cycle <= 6 do
    local counts = {}
    for k, _ in pairs(cur) do
      local nbrs, nn = neighbors4(k)
      local i = 1
      while i <= nn do
        local nk = nbrs[i]
        counts[nk] = (counts[nk] or 0) + 1
        i = i + 1
      end
    end
    local nxt = {}
    for k, c in pairs(counts) do
      local was = cur[k]
      if was and (c == 2 or c == 3) then
        nxt[k] = true
      elseif not was and c == 3 then
        nxt[k] = true
      end
    end
    cur = nxt
    cycle = cycle + 1
  end

  local p2 = 0
  for _ in pairs(cur) do
    p2 = p2 + 1
  end

  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end
