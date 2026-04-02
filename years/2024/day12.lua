return function(path)
  local lines = readLines(path)
  local rows = #lines
  local cols = lines[1] and #lines[1] or 0

  local function at(r, c)
    if r < 1 or r > rows or c < 1 or c > cols then
      return nil
    end
    return lines[r]:sub(c, c)
  end

  local visited = {}
  local part1, part2 = 0, 0

  for sr = 1, rows do
    for sc = 1, cols do
      local key0 = sr .. ',' .. sc
      if not visited[key0] then
        local ch = at(sr, sc)
        local stack = { { sr, sc } }
        local cells = {}
        local cellset = {}
        while #stack > 0 do
          local p = table.remove(stack)
          local r, c = p[1], p[2]
          local k = r .. ',' .. c
          if not visited[k] and at(r, c) == ch then
            visited[k] = true
            cells[#cells + 1] = { r, c }
            cellset[k] = true
            for _, d in ipairs { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } } do
              stack[#stack + 1] = { r + d[1], c + d[2] }
            end
          end
        end

        local area = #cells
        local perim = 0
        for _, p in ipairs(cells) do
          local r, c = p[1], p[2]
          for _, d in ipairs { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } } do
            local k2 = (r + d[1]) .. ',' .. (c + d[2])
            if not cellset[k2] then
              perim = perim + 1
            end
          end
        end

        local sides = 0
        for _, p in ipairs(cells) do
          local r, c = p[1], p[2]
          local corners = {
            { { -1, 0 }, { 0, -1 }, { -1, -1 } },
            { { -1, 0 }, { 0, 1 }, { -1, 1 } },
            { { 1, 0 }, { 0, -1 }, { 1, -1 } },
            { { 1, 0 }, { 0, 1 }, { 1, 1 } },
          }
          for _, t in ipairs(corners) do
            local a = cellset[(r + t[1][1]) .. ',' .. (c + t[1][2])]
            local b = cellset[(r + t[2][1]) .. ',' .. (c + t[2][2])]
            local diag = cellset[(r + t[3][1]) .. ',' .. (c + t[3][2])]
            if (a and b and not diag) or (not a and not b) then
              sides = sides + 1
            end
          end
        end

        part1 = part1 + area * perim
        part2 = part2 + area * sides
      end
    end
  end

  print('Part 1: ' .. part1)
  print('Part 2: ' .. part2)
end
