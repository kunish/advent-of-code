return function(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = #lines[1]
  local gr, gc, gdr, gdc
  for r = 1, rows do
    for c = 1, cols do
      local ch = lines[r]:sub(c, c)
      if ch == '^' then
        gr, gc, gdr, gdc = r, c, -1, 0
      elseif ch == '>' then
        gr, gc, gdr, gdc = r, c, 0, 1
      elseif ch == 'v' then
        gr, gc, gdr, gdc = r, c, 1, 0
      elseif ch == '<' then
        gr, gc, gdr, gdc = r, c, 0, -1
      end
    end
  end

  local function cell(r, c)
    return lines[r]:sub(c, c)
  end

  local function right(dr, dc)
    return dc, -dr
  end

  local function simulate(obr, obc)
    local r, c, dr, dc = gr, gc, gdr, gdc
    local seen = {}
    while true do
      local key = r .. ',' .. c .. ',' .. dr .. ',' .. dc
      if seen[key] then
        return true
      end
      seen[key] = true
      local nr, nc = r + dr, c + dc
      if nr < 1 or nr > rows or nc < 1 or nc > cols then
        return false
      end
      local ch = cell(nr, nc)
      if (obr and nr == obr and nc == obc) or ch == '#' then
        dr, dc = right(dr, dc)
      else
        r, c = nr, nc
      end
    end
  end

  local function walk_path()
    local r, c, dr, dc = gr, gc, gdr, gdc
    local visited = {}
    visited[r .. ',' .. c] = true
    while true do
      local nr, nc = r + dr, c + dc
      if nr < 1 or nr > rows or nc < 1 or nc > cols then
        break
      end
      local ch = cell(nr, nc)
      if ch == '#' then
        dr, dc = right(dr, dc)
      else
        r, c = nr, nc
        visited[r .. ',' .. c] = true
      end
    end
    return visited
  end

  local path_cells = walk_path()
  local part1 = 0
  for _ in pairs(path_cells) do
    part1 = part1 + 1
  end

  local part2 = 0
  for key, _ in pairs(path_cells) do
    local sr, sc = key:match('^(%d+),(%d+)$')
    local obr, obc = tonumber(sr), tonumber(sc)
    if not (obr == gr and obc == gc) and cell(obr, obc) == '.' then
      if simulate(obr, obc) then
        part2 = part2 + 1
      end
    end
  end

  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
