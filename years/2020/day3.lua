local function trees_on_slope(grid, dr, dc)
  local h = #grid
  if h == 0 then
    return 0
  end
  local w = #grid[1]
  local r, c, t = 1, 1, 0
  while r <= h do
    local row = grid[r]
    local cc = ((c - 1) % w) + 1
    if row:sub(cc, cc) == '#' then
      t = t + 1
    end
    r = r + dr
    c = c + dc
  end
  return t
end

return function(path)
  local lines = readLines(path)
  local grid = {}
  local i = 1
  while i <= #lines do
    if lines[i] ~= '' then
      grid[#grid + 1] = lines[i]
    end
    i = i + 1
  end

  local part1 = trees_on_slope(grid, 1, 3)
  local slopes = { { 1, 1 }, { 3, 1 }, { 5, 1 }, { 7, 1 }, { 1, 2 } }
  local part2 = 1
  local s = 1
  while s <= #slopes do
    part2 = part2 * trees_on_slope(grid, slopes[s][2], slopes[s][1])
    s = s + 1
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end
