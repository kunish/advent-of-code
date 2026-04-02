return function(path)
  local lines = readLines(path)

  local function parse_nums(line)
    local t = {}
    local k = 0
    for x in line:gmatch('%d+') do
      k = k + 1
      t[k] = tonumber(x)
    end
    return t
  end

  local function is_safe(seq)
    local m = #seq
    if m < 2 then
      return true
    end
    local inc = seq[2] > seq[1]
    for i = 2, m do
      local d = seq[i] - seq[i - 1]
      if inc and d <= 0 then
        return false
      end
      if not inc and d >= 0 then
        return false
      end
      if d < 0 then
        d = -d
      end
      if d < 1 or d > 3 then
        return false
      end
    end
    return true
  end

  local function safe_with_removal(seq)
    if is_safe(seq) then
      return true
    end
    local m = #seq
    for skip = 1, m do
      local t = {}
      local k = 0
      for j = 1, m do
        if j ~= skip then
          k = k + 1
          t[k] = seq[j]
        end
      end
      if is_safe(t) then
        return true
      end
    end
    return false
  end

  local part1, part2 = 0, 0
  for _, line in ipairs(lines) do
    if line ~= '' then
      local seq = parse_nums(line)
      if is_safe(seq) then
        part1 = part1 + 1
      end
      if safe_with_removal(seq) then
        part2 = part2 + 1
      end
    end
  end
  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
