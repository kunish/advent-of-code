local EX = {
  ['|'] = { { -1, 0 }, { 1, 0 } },
  ['-'] = { { 0, -1 }, { 0, 1 } },
  ['L'] = { { -1, 0 }, { 0, 1 } },
  ['J'] = { { -1, 0 }, { 0, -1 } },
  ['7'] = { { 1, 0 }, { 0, -1 } },
  ['F'] = { { 1, 0 }, { 0, 1 } },
}

local function has_exit(ch, dr, dc)
  local e = EX[ch]
  if not e then
    return false
  end
  for i = 1, #e do
    local d = e[i]
    if d[1] == dr and d[2] == dc then
      return true
    end
  end
  return false
end

local function connects(grid, r, c, nr, nc, sch)
  local dr, dc = nr - r, nc - c
  local ch = sch or grid[r][c]
  local ch2 = grid[nr][nc]
  if ch == '.' or ch2 == '.' then
    return false
  end
  return has_exit(ch, dr, dc) and has_exit(ch2, -dr, -dc)
end

local function infer_s(grid, sr, sc, rows, cols)
  for _, ch in ipairs({ '|', '-', 'L', 'J', '7', 'F' }) do
    local n = 0
    for i = 1, #EX[ch] do
      local d = EX[ch][i]
      local nr, nc = sr + d[1], sc + d[2]
      if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols then
        if connects(grid, sr, sc, nr, nc, ch) then
          n = n + 1
        end
      end
    end
    if n == 2 then
      return ch
    end
  end
  error('cannot infer S')
end

local function day10(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = #lines[1]
  local grid = {}
  local sr, sc = 1, 1
  for r = 1, rows do
    grid[r] = {}
    for c = 1, cols do
      local ch = lines[r]:sub(c, c)
      grid[r][c] = ch
      if ch == 'S' then
        sr, sc = r, c
      end
    end
  end
  local s_ch = infer_s(grid, sr, sc, rows, cols)
  grid[sr][sc] = s_ch

  local function step(r, c, pr, pc)
    local ch = grid[r][c]
    for i = 1, #EX[ch] do
      local d = EX[ch][i]
      local nr, nc = r + d[1], c + d[2]
      if not (nr == pr and nc == pc) then
        if nr >= 1 and nr <= rows and nc >= 1 and nc <= cols then
          if connects(grid, r, c, nr, nc) then
            return nr, nc
          end
        end
      end
    end
    return nil, nil
  end

  local r, c = step(sr, sc, -1, -1)
  local pr, pc = sr, sc
  local dist = 1
  local loop = {}
  loop[sr * 4096 + sc] = true
  while not (r == sr and c == sc) do
    loop[r * 4096 + c] = true
    local nr, nc = step(r, c, pr, pc)
    pr, pc = r, c
    r, c = nr, nc
    dist = dist + 1
  end

  local part1 = dist // 2

  local part2 = 0
  for rr = 1, rows do
    local crossings = 0
    for cc = 1, cols do
      if loop[rr * 4096 + cc] then
        local ch = grid[rr][cc]
        if ch == '|' or ch == 'L' or ch == 'J' then
          crossings = crossings + 1
        end
      else
        if crossings % 2 == 1 then
          part2 = part2 + 1
        end
      end
    end
  end

  print(string.format('Part 1: %d', part1))
  print(string.format('Part 2: %d', part2))
end

return function(p)
  return day10(p)
end
