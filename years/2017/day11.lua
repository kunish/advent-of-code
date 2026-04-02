local dirs = {
  n = { 0, 1, -1 },
  ne = { 1, 0, -1 },
  se = { 1, -1, 0 },
  s = { 0, -1, 1 },
  sw = { -1, 0, 1 },
  nw = { -1, 1, 0 },
}

local function add(a, b)
  return { a[1] + b[1], a[2] + b[2], a[3] + b[3] }
end

local function dist(c)
  return (math.abs(c[1]) + math.abs(c[2]) + math.abs(c[3])) // 2
end

local function day11(path)
  local lines = readLines(path)
  local line = lines[1] or ''
  local pos = { 0, 0, 0 }
  local maxd = 0
  for token in line:gmatch('[^,]+') do
    local w = token:match('^%s*(.-)%s*$')
    local d = dirs[w]
    if d then
      pos = add(pos, d)
      local d0 = dist(pos)
      if d0 > maxd then
        maxd = d0
      end
    end
  end

  print(string.format('Part 1: %d', dist(pos)))
  print(string.format('Part 2: %d', maxd))
end

return function(path)
  return day11(path)
end
