local function day19(path)
  local lines = readLines(path)
  local maxw = 0
  for _, ln in ipairs(lines) do
    if #ln > maxw then
      maxw = #ln
    end
  end

  local grid = {}
  for r, ln in ipairs(lines) do
    local row = {}
    for c = 1, maxw do
      row[c] = ln:sub(c, c)
      if row[c] == '' then
        row[c] = ' '
      end
    end
    grid[r] = row
  end

  local rows = #grid
  local start_c = nil
  for c = 1, maxw do
    if grid[1][c] == '|' then
      start_c = c
      break
    end
  end

  local r, c = 1, start_c
  local dr, dc = 1, 0
  local letters = {}
  local steps = 0

  while r >= 1 and r <= rows and c >= 1 and c <= maxw do
    local ch = grid[r][c]
    if ch == ' ' then
      break
    end
    steps = steps + 1
    if ch >= 'A' and ch <= 'Z' then
      letters[#letters + 1] = ch
    end

    if ch == '+' then
      if dr ~= 0 then
        if grid[r][c + 1] and grid[r][c + 1] ~= ' ' then
          dr, dc = 0, 1
        elseif grid[r][c - 1] and grid[r][c - 1] ~= ' ' then
          dr, dc = 0, -1
        end
      else
        if grid[r + 1] and grid[r + 1][c] and grid[r + 1][c] ~= ' ' then
          dr, dc = 1, 0
        elseif grid[r - 1] and grid[r - 1][c] and grid[r - 1][c] ~= ' ' then
          dr, dc = -1, 0
        end
      end
    end

    r = r + dr
    c = c + dc
  end

  print(string.format('Part 1: %s', table.concat(letters)))
  print(string.format('Part 2: %d', steps))
end

return function(path)
  return day19(path)
end
