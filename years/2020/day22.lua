return function(path)
  local lines = readLines(path)
  local p1 = {}
  local p2 = {}
  local mode = 1
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line == '' then
      mode = 2
    elseif string.match(line, '^Player') then
      -- skip
    else
      local v = tonumber(line)
      if v then
        if mode == 1 then
          p1[#p1 + 1] = v
        else
          p2[#p2 + 1] = v
        end
      end
    end
    i = i + 1
  end

  local function copy_deck(d)
    local out = {}
    local j = 1
    while j <= #d do
      out[j] = d[j]
      j = j + 1
    end
    return out
  end

  local function score(d)
    local s = 0
    local m = #d
    local j = 1
    while j <= #d do
      s = s + d[j] * (m - j + 1)
      j = j + 1
    end
    return s
  end

  local a = copy_deck(p1)
  local b = copy_deck(p2)
  while #a > 0 and #b > 0 do
    local ca = a[1]
    local cb = b[1]
    local j = 1
    while j < #a do
      a[j] = a[j + 1]
      j = j + 1
    end
    a[#a] = nil
    j = 1
    while j < #b do
      b[j] = b[j + 1]
      j = j + 1
    end
    b[#b] = nil
    if ca > cb then
      a[#a + 1] = ca
      a[#a + 1] = cb
    else
      b[#b + 1] = cb
      b[#b + 1] = ca
    end
  end

  local part1 = 0
  if #a > 0 then
    part1 = score(a)
  else
    part1 = score(b)
  end

  local function deck_key(d, start_idx)
    local parts = {}
    local j = start_idx
    while j <= #d do
      parts[#parts + 1] = tostring(d[j])
      j = j + 1
    end
    return table.concat(parts, ',')
  end

  local function recursive_combat(aa, bb)
    local seen = {}
    while #aa > 0 and #bb > 0 do
      local ka = deck_key(aa, 1)
      local kb = deck_key(bb, 1)
      local key = ka .. '|' .. kb
      if seen[key] then
        return 1
      end
      seen[key] = true

      local ca = aa[1]
      local cb = bb[1]
      local j = 1
      while j < #aa do
        aa[j] = aa[j + 1]
        j = j + 1
      end
      aa[#aa] = nil
      j = 1
      while j < #bb do
        bb[j] = bb[j + 1]
        j = j + 1
      end
      bb[#bb] = nil

      local winner
      if #aa >= ca and #bb >= cb then
        local suba = {}
        local subb = {}
        local t = 1
        while t <= ca do
          suba[t] = aa[t]
          t = t + 1
        end
        t = 1
        while t <= cb do
          subb[t] = bb[t]
          t = t + 1
        end
        winner = recursive_combat(suba, subb)
      else
        if ca > cb then
          winner = 1
        else
          winner = 2
        end
      end

      if winner == 1 then
        aa[#aa + 1] = ca
        aa[#aa + 1] = cb
      else
        bb[#bb + 1] = cb
        bb[#bb + 1] = ca
      end
    end
    if #aa > 0 then
      return 1
    end
    return 2
  end

  local ra = copy_deck(p1)
  local rb = copy_deck(p2)
  recursive_combat(ra, rb)
  local part2 = 0
  if #ra > 0 then
    part2 = score(ra)
  else
    part2 = score(rb)
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
