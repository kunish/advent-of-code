local function day3(path)
  local lines = readLines(path)
  local claims = {}
  local maxx, maxy = 0, 0
  for li = 1, #lines do
    local line = lines[li]
    local id, x, y, w, h = line:match('#(%d+) @ (%d+),(%d+): (%d+)x(%d+)')
    if id then
      id = tonumber(id)
      x = tonumber(x)
      y = tonumber(y)
      w = tonumber(w)
      h = tonumber(h)
      claims[#claims + 1] = { id = id, x = x, y = y, w = w, h = h }
      local rx = x + w
      local ry = y + h
      if rx > maxx then
        maxx = rx
      end
      if ry > maxy then
        maxy = ry
      end
    end
  end

  local grid = {}
  for ci = 1, #claims do
    local c = claims[ci]
    for yy = c.y, c.y + c.h - 1 do
      local row = grid[yy]
      if not row then
        row = {}
        grid[yy] = row
      end
      for xx = c.x, c.x + c.w - 1 do
        row[xx] = (row[xx] or 0) + 1
      end
    end
  end

  local overlap = 0
  for yy, row in pairs(grid) do
    for xx, v in pairs(row) do
      if v >= 2 then
        overlap = overlap + 1
      end
    end
  end
  local part1 = overlap

  local part2 = 0
  for ci = 1, #claims do
    local c = claims[ci]
    local ok = true
    for yy = c.y, c.y + c.h - 1 do
      local row = grid[yy]
      for xx = c.x, c.x + c.w - 1 do
        if not row or row[xx] ~= 1 then
          ok = false
          break
        end
      end
      if not ok then
        break
      end
    end
    if ok then
      part2 = c.id
      break
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day3(path)
end
