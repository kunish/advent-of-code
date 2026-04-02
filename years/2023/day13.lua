local function parse_grids(lines)
  local grids = {}
  local cur = {}
  for i = 1, #lines do
    local line = lines[i]
    if line == '' then
      if #cur > 0 then
        grids[#grids + 1] = cur
        cur = {}
      end
    else
      cur[#cur + 1] = line
    end
  end
  if #cur > 0 then
    grids[#grids + 1] = cur
  end
  return grids
end

local function row_diff(a, b)
  local n = 0
  for i = 1, #a do
    if a:sub(i, i) ~= b:sub(i, i) then
      n = n + 1
    end
  end
  return n
end

local function col_diff(grid, c1, c2)
  local n = 0
  for r = 1, #grid do
    if grid[r]:sub(c1, c1) ~= grid[r]:sub(c2, c2) then
      n = n + 1
    end
  end
  return n
end

local function horiz_reflect(grid, rows, cols, after_row, max_diff)
  local d = 0
  local lo = after_row
  local hi = after_row + 1
  while lo >= 1 and hi <= rows do
    d = d + row_diff(grid[lo], grid[hi])
    if d > max_diff then
      return false
    end
    lo = lo - 1
    hi = hi + 1
  end
  return d == max_diff
end

local function vert_reflect(grid, rows, cols, after_col, max_diff)
  local d = 0
  local lo = after_col
  local hi = after_col + 1
  while lo >= 1 and hi <= cols do
    d = d + col_diff(grid, lo, hi)
    if d > max_diff then
      return false
    end
    lo = lo - 1
    hi = hi + 1
  end
  return d == max_diff
end

local function score_grid(grid, max_diff)
  local rows = #grid
  local cols = #grid[1]
  for r = 1, rows - 1 do
    if horiz_reflect(grid, rows, cols, r, max_diff) then
      return 100 * r
    end
  end
  for c = 1, cols - 1 do
    if vert_reflect(grid, rows, cols, c, max_diff) then
      return c
    end
  end
  return 0
end

local function day13(path)
  local lines = readLines(path)
  local grids = parse_grids(lines)
  local p1, p2 = 0, 0
  for i = 1, #grids do
    p1 = p1 + score_grid(grids[i], 0)
    p2 = p2 + score_grid(grids[i], 1)
  end
  print(string.format('Part 1: %d', p1))
  print(string.format('Part 2: %d', p2))
end

return function(p)
  return day13(p)
end
