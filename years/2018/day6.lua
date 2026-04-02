local function day6(path)
  local lines = readLines(path)
  local pts = {}
  for li = 1, #lines do
    local line = lines[li]
    local x, y = line:match('(%d+), (%d+)')
    if x then
      pts[#pts + 1] = { x = tonumber(x), y = tonumber(y) }
    end
  end

  local minx, maxx = pts[1].x, pts[1].x
  local miny, maxy = pts[1].y, pts[1].y
  for i = 2, #pts do
    local p = pts[i]
    if p.x < minx then
      minx = p.x
    end
    if p.x > maxx then
      maxx = p.x
    end
    if p.y < miny then
      miny = p.y
    end
    if p.y > maxy then
      maxy = p.y
    end
  end

  local pad = 2
  local ax, bx = minx - pad, maxx + pad
  local ay, by = miny - pad, maxy + pad

  local areas = {}
  local infinite = {}

  for y = ay, by do
    for x = ax, bx do
      local bestd = nil
      local besti = nil
      local tie = false
      for pi = 1, #pts do
        local p = pts[pi]
        local d = math.abs(x - p.x) + math.abs(y - p.y)
        if bestd == nil or d < bestd then
          bestd = d
          besti = pi
          tie = false
        elseif d == bestd then
          tie = true
        end
      end
      if not tie and besti then
        areas[besti] = (areas[besti] or 0) + 1
        if x == ax or x == bx or y == ay or y == by then
          infinite[besti] = true
        end
      end
    end
  end

  local part1 = 0
  for pi = 1, #pts do
    if not infinite[pi] then
      local a = areas[pi] or 0
      if a > part1 then
        part1 = a
      end
    end
  end

  local part2 = 0
  for y = ay, by do
    for x = ax, bx do
      local s = 0
      for pi = 1, #pts do
        local p = pts[pi]
        s = s + math.abs(x - p.x) + math.abs(y - p.y)
      end
      if s < 10000 then
        part2 = part2 + 1
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day6(path)
end
