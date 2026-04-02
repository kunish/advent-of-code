local function day6(path)
  local lines = readLines(path)
  local s = lines[1] or ''

  local function first_marker(n)
    local count = {}
    local bad = 0
    for i = 1, n do
      local c = s:sub(i, i)
      local v = (count[c] or 0) + 1
      count[c] = v
      if v == 2 then
        bad = bad + 1
      end
    end
    if bad == 0 then
      return n
    end
    for i = n + 1, #s do
      local out = s:sub(i - n, i - n)
      local vo = count[out] or 0
      if vo == 2 then
        bad = bad - 1
      end
      count[out] = vo - 1

      local inc = s:sub(i, i)
      local vi = (count[inc] or 0) + 1
      count[inc] = vi
      if vi == 2 then
        bad = bad + 1
      end
      if bad == 0 then
        return i
      end
    end
    return nil
  end

  print(string.format('Part 1: %d', first_marker(4)))
  print(string.format('Part 2: %d', first_marker(14)))
end

return function(p)
  return day6(p)
end
