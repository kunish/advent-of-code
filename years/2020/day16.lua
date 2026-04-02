return function(path)
  local lines = readLines(path)
  local rules = {}
  local i = 1
  while i <= #lines and lines[i] ~= '' do
    local line = lines[i]
    local name, rest = string.match(line, '(.-): (.+)')
    if name then
      local ranges = {}
      for lo, hi in string.gmatch(rest, '(%d+)%-(%d+)') do
        ranges[#ranges + 1] = { tonumber(lo), tonumber(hi) }
      end
      rules[name] = ranges
    end
    i = i + 1
  end

  while i <= #lines and not string.match(lines[i], '^your ticket:') do
    i = i + 1
  end
  i = i + 1
  local your = {}
  local yt = 1
  for num in string.gmatch(lines[i], '(%d+)') do
    your[yt] = tonumber(num)
    yt = yt + 1
  end

  while i <= #lines and not string.match(lines[i], '^nearby tickets:') do
    i = i + 1
  end
  i = i + 1

  local nearby = {}
  local nt = 0
  while i <= #lines do
    if lines[i] ~= '' then
      nt = nt + 1
      local row = {}
      local k = 1
      for num in string.gmatch(lines[i], '(%d+)') do
        row[k] = tonumber(num)
        k = k + 1
      end
      nearby[nt] = row
    end
    i = i + 1
  end

  local function valid_for_any(v)
    for _, ranges in pairs(rules) do
      local r = 1
      while r <= #ranges do
        local lo, hi = ranges[r][1], ranges[r][2]
        if v >= lo and v <= hi then
          return true
        end
        r = r + 1
      end
    end
    return false
  end

  local part1 = 0
  local valid_tickets = {}
  local vt = 0
  local ti = 1
  while ti <= nt do
    local t = nearby[ti]
    local ok = true
    local fi = 1
    while fi <= #t do
      local v = t[fi]
      if not valid_for_any(v) then
        part1 = part1 + v
        ok = false
      end
      fi = fi + 1
    end
    if ok then
      vt = vt + 1
      valid_tickets[vt] = t
    end
    ti = ti + 1
  end

  local field_names = {}
  local nf = 0
  for name, _ in pairs(rules) do
    nf = nf + 1
    field_names[nf] = name
  end

  local ncols = #your
  local possible = {}
  local c = 1
  while c <= ncols do
    possible[c] = {}
    local fn = 1
    while fn <= nf do
      local name = field_names[fn]
      local ranges = rules[name]
      local all_ok = true
      local ti2 = 1
      while ti2 <= vt and all_ok do
        local v = valid_tickets[ti2][c]
        local in_range = false
        local r = 1
        while r <= #ranges do
          local lo, hi = ranges[r][1], ranges[r][2]
          if v >= lo and v <= hi then
            in_range = true
            break
          end
          r = r + 1
        end
        if not in_range then
          all_ok = false
        end
        ti2 = ti2 + 1
      end
      if all_ok then
        possible[c][name] = true
      end
      fn = fn + 1
    end
    c = c + 1
  end

  local assigned = {}
  local changed = true
  while changed do
    changed = false
    local col = 1
    while col <= ncols do
      local cnt = 0
      local only_name = nil
      for name, ok in pairs(possible[col]) do
        if ok and not assigned[name] then
          cnt = cnt + 1
          only_name = name
        end
      end
      if cnt == 1 then
        assigned[only_name] = col
        local col2 = 1
        while col2 <= ncols do
          if col2 ~= col then
            possible[col2][only_name] = nil
          end
          col2 = col2 + 1
        end
        changed = true
      end
      col = col + 1
    end
  end

  local part2 = 1
  for name, col in pairs(assigned) do
    if string.sub(name, 1, 9) == 'departure' then
      part2 = part2 * your[col]
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
