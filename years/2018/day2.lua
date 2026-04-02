local function letter_counts(s)
  local c = {}
  local n = #s
  for i = 1, n do
    local ch = s:sub(i, i)
    c[ch] = (c[ch] or 0) + 1
  end
  return c
end

local function has_exactly(c, k)
  for _, v in pairs(c) do
    if v == k then
      return true
    end
  end
  return false
end

local function day2(path)
  local lines = readLines(path)
  local n2, n3 = 0, 0
  for li = 1, #lines do
    local line = lines[li]
    if line ~= '' then
      local c = letter_counts(line)
      if has_exactly(c, 2) then
        n2 = n2 + 1
      end
      if has_exactly(c, 3) then
        n3 = n3 + 1
      end
    end
  end
  local part1 = n2 * n3

  local part2 = ''
  local found = false
  for i = 1, #lines do
    local a = lines[i]
    if a ~= '' then
      for j = i + 1, #lines do
        local b = lines[j]
        if b ~= '' and #a == #b then
          local diff = 0
          local pos = 0
          for k = 1, #a do
            if a:sub(k, k) ~= b:sub(k, k) then
              diff = diff + 1
              pos = k
              if diff > 1 then
                break
              end
            end
          end
          if diff == 1 then
            part2 = a:sub(1, pos - 1) .. a:sub(pos + 1)
            found = true
            break
          end
        end
      end
    end
    if found then
      break
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %s', part2))
end

return function(path)
  return day2(path)
end
