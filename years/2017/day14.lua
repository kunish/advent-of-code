local function knot_hash_hex(key)
  local lengths = {}
  for i = 1, #key do
    lengths[i] = key:byte(i)
  end
  local extra = { 17, 31, 73, 47, 23 }
  for j = 1, #extra do
    lengths[#lengths + 1] = extra[j]
  end

  local n = 256
  local list = {}
  for i = 1, n do
    list[i] = i - 1
  end

  local pos = 0
  local skip = 0
  for _ = 1, 64 do
    for _, lg in ipairs(lengths) do
      for k = 0, math.floor(lg / 2) - 1 do
        local a = (pos + k) % n + 1
        local b = (pos + lg - 1 - k) % n + 1
        list[a], list[b] = list[b], list[a]
      end
      pos = (pos + lg + skip) % n
      skip = skip + 1
    end
  end

  local hex = {}
  for i = 0, 15 do
    local xorv = 0
    for j = 1, 16 do
      xorv = xorv ~ list[i * 16 + j]
    end
    hex[#hex + 1] = string.format('%02x', xorv)
  end
  return table.concat(hex)
end

local function hex_to_bits(hex)
  local bits = {}
  for i = 1, #hex do
    local c = hex:sub(i, i)
    local v = tonumber(c, 16)
    for b = 3, 0, -1 do
      bits[#bits + 1] = (v >> b) & 1
    end
  end
  return bits
end

local function day14(path)
  local lines = readLines(path)
  local key_base = (lines[1] or ''):gsub('%s+', '')

  local grid = {}
  local used = 0
  for row = 0, 127 do
    local h = knot_hash_hex(key_base .. '-' .. row)
    local bits = hex_to_bits(h)
    grid[row] = {}
    for col = 0, 127 do
      local b = bits[col + 1]
      grid[row][col] = b
      used = used + b
    end
  end

  local visited = {}
  local function key(r, c)
    return r * 128 + c
  end

  local function flood(r, c)
    local stack = { { r, c } }
    visited[key(r, c)] = true
    while #stack > 0 do
      local cur = table.remove(stack)
      local cr, cc = cur[1], cur[2]
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nr, nc = cr + d[1], cc + d[2]
        if nr >= 0 and nr < 128 and nc >= 0 and nc < 128 and grid[nr][nc] == 1 then
          local k = key(nr, nc)
          if not visited[k] then
            visited[k] = true
            stack[#stack + 1] = { nr, nc }
          end
        end
      end
    end
  end

  local regions = 0
  for r = 0, 127 do
    for c = 0, 127 do
      if grid[r][c] == 1 and not visited[key(r, c)] then
        regions = regions + 1
        flood(r, c)
      end
    end
  end

  print(string.format('Part 1: %d', used))
  print(string.format('Part 2: %d', regions))
end

return function(path)
  return day14(path)
end
