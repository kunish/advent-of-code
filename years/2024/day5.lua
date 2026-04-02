return function(path)
  local lines = readLines(path)
  local rules = {}
  local i = 1
  while i <= #lines and lines[i] ~= '' do
    local a, b = lines[i]:match('^(%d+)|(%d+)$')
    if a then
      a = tonumber(a)
      b = tonumber(b)
      if not rules[a] then
        rules[a] = {}
      end
      rules[a][b] = true
    end
    i = i + 1
  end
  i = i + 1 -- skip blank

  local function valid_order(pages)
    local m = #pages
    for ii = 1, m do
      for jj = ii + 1, m do
        local x, y = pages[ii], pages[jj]
        if rules[y] and rules[y][x] then
          return false
        end
      end
    end
    return true
  end

  local function sort_pages(pages)
    local m = #pages
    local changed = true
    while changed do
      changed = false
      for j = 1, m - 1 do
        local a, b = pages[j], pages[j + 1]
        if rules[b] and rules[b][a] then
          pages[j], pages[j + 1] = pages[j + 1], pages[j]
          changed = true
        end
      end
    end
  end

  local part1, part2 = 0, 0
  while i <= #lines do
    local line = lines[i]
    if line ~= '' then
      local pages = {}
      local k = 0
      for x in line:gmatch('%d+') do
        k = k + 1
        pages[k] = tonumber(x)
      end
      if valid_order(pages) then
        part1 = part1 + pages[(k + 1) / 2]
      else
        sort_pages(pages)
        part2 = part2 + pages[(k + 1) / 2]
      end
    end
    i = i + 1
  end

  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
