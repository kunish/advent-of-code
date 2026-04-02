local FONT = {
  ["..##...#..#.#....##....##....########....##....##....##....#"] = "A",
  ["#####.#....##....######.#....##....##....##....##....######."] = "B",
  [".####.#....##.....#.....#.....#.....#.....#.....#....#.####."] = "C",
  ["######.....#.....#####.#.....#.....#.....#.....#.....######"] = "E",
  ["######.....#.....#####.#.....#.....#.....#.....#.....#....."] = "F",
  [".####.#....##.....#.....#.....#..####....##....##...##.###.#"] = "G",
  ["#....##....##....##....########....##....##....##....##....#"] = "H",
  ["...###....#.....#.....#.....#.....#.....#.#...#.#...#..###.."] = "J",
  ["#....##...#.#..#..#.#...##....##....#.#...#..#..#...#.#....#"] = "K",
  ["#.....#.....#.....#.....#.....#.....#.....#.....#.....######"] = "L",
  ["#....###...###...##.#..##.#..##..#.##..#.##...###...###....#"] = "N",
  ["#####.#....##....##....######.#.....#.....#.....#.....#....."] = "P",
  ["#####.#....##....##....######.#..#..#...#.#...#.#....##....#"] = "R",
  ["#....##....#.#..#...##....##....##...#..#.#....##....##....#"] = "X",
  ["######.....#.....#....#....#....#....#....#.....#.....######"] = "Z",
}

local function ocr_grid(grid, h, w)
  local col_has = {}
  for c = 1, w do
    for r = 1, h do
      if grid[r][c] then
        col_has[c] = true
        break
      end
    end
  end

  local result = {}
  local c = 1
  while c <= w do
    if not col_has[c] then
      c = c + 1
    else
      local pat = {}
      for r = 1, h do
        for dc = 0, 5 do
          local cc = c + dc
          pat[#pat + 1] = (cc <= w and grid[r][cc]) and '#' or '.'
        end
      end
      local key = table.concat(pat)
      result[#result + 1] = FONT[key] or '?'
      c = c + 6
      while c <= w and not col_has[c] do
        c = c + 1
      end
    end
  end
  return table.concat(result)
end

local function day10(path)
  local lines = readLines(path)
  local pts = {}
  for li = 1, #lines do
    local line = lines[li]
    local x, y, vx, vy = line:match('position=<%s*([%-%d]+),%s*([%-%d]+)> velocity=<%s*(%-?%d+),%s*([%-%d]+)>')
    if x then
      pts[#pts + 1] = { x = tonumber(x), y = tonumber(y), vx = tonumber(vx), vy = tonumber(vy) }
    end
  end

  local function bbox(t)
    local minx, maxx = pts[1].x + pts[1].vx * t, pts[1].x + pts[1].vx * t
    local miny, maxy = pts[1].y + pts[1].vy * t, pts[1].y + pts[1].vy * t
    for i = 2, #pts do
      local p = pts[i]
      local px = p.x + p.vx * t
      local py = p.y + p.vy * t
      if px < minx then minx = px end
      if px > maxx then maxx = px end
      if py < miny then miny = py end
      if py > maxy then maxy = py end
    end
    return (maxx - minx + 1) * (maxy - miny + 1), minx, miny, maxx, maxy
  end

  local best_t = 0
  local best_a = nil
  for t = 0, 20000 do
    local a = bbox(t)
    if best_a == nil or a < best_a then
      best_a = a
      best_t = t
    end
  end

  local _, minx, miny, maxx, maxy = bbox(best_t)
  local w = maxx - minx + 1
  local h = maxy - miny + 1
  local grid = {}
  for r = 1, h do
    grid[r] = {}
    for c = 1, w do
      grid[r][c] = false
    end
  end
  for i = 1, #pts do
    local p = pts[i]
    local cx = p.x + p.vx * best_t - minx + 1
    local cy = p.y + p.vy * best_t - miny + 1
    if cx >= 1 and cx <= w and cy >= 1 and cy <= h then
      grid[cy][cx] = true
    end
  end

  local part1 = ocr_grid(grid, h, w)
  local part2 = best_t

  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %d', part2))
end

return function(path)
  return day10(path)
end
