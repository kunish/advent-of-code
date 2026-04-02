local function day5(path)
  local lines = readLines(path)
  local base = {}
  for i, line in ipairs(lines) do
    if line ~= '' then
      base[i] = tonumber(line)
    end
  end

  local function steps(rule2)
    local jm = {}
    for idx, v in ipairs(base) do
      jm[idx] = v
    end
    local i, count = 1, 0
    while i >= 1 and i <= #jm do
      local off = jm[i]
      if rule2 then
        if off >= 3 then
          jm[i] = off - 1
        else
          jm[i] = off + 1
        end
      else
        jm[i] = off + 1
      end
      i = i + off
      count = count + 1
    end
    return count
  end

  print(string.format('Part 1: %d', steps(false)))
  print(string.format('Part 2: %d', steps(true)))
end

return function(path)
  return day5(path)
end
