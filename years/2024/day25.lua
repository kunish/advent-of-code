return function(path)
  local lines = readLines(path)
  local schematics = {}
  local cur = {}
  for _, line in ipairs(lines) do
    if line == '' then
      if #cur > 0 then
        schematics[#schematics + 1] = cur
        cur = {}
      end
    else
      cur[#cur + 1] = line
    end
  end
  if #cur > 0 then
    schematics[#schematics + 1] = cur
  end

  local locks = {}
  local keys = {}
  for si = 1, #schematics do
    local g = schematics[si]
    local is_lock = g[1]:find('#', 1, true) and true or false
    local heights = {}
    local cols = #g[1]
    for c = 1, cols do
      local h = 0
      for r = 2, #g - 1 do
        if g[r]:sub(c, c) == '#' then
          h = h + 1
        end
      end
      heights[c] = h
    end
    if is_lock then
      locks[#locks + 1] = heights
    else
      keys[#keys + 1] = heights
    end
  end

  local count = 0
  for li = 1, #locks do
    for ki = 1, #keys do
      local ok = true
      local L, K = locks[li], keys[ki]
      for c = 1, #L do
        if L[c] + K[c] > 5 then
          ok = false
          break
        end
      end
      if ok then
        count = count + 1
      end
    end
  end

  print(string.format('Part 1: %d', count))
  print('Part 2: ')
end
