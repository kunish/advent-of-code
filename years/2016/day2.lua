local function day2(path)
  local lines = readLines(path)

  local grid3 = {
    { '1', '2', '3' },
    { '4', '5', '6' },
    { '7', '8', '9' },
  }

  local function key3(r, c)
    if r < 1 or r > 3 or c < 1 or c > 3 then
      return nil
    end
    return grid3[r][c]
  end

  local diamond = {
    { nil, nil, '1', nil, nil },
    { nil, '2', '3', '4', nil },
    { '5', '6', '7', '8', '9' },
    { nil, 'A', 'B', 'C', nil },
    { nil, nil, 'D', nil, nil },
  }

  local function keyD(r, c)
    if r < 1 or r > 5 or c < 1 or c > 5 then
      return nil
    end
    return diamond[r][c]
  end

  local dr = { U = -1, D = 1, L = 0, R = 0 }
  local dc = { U = 0, D = 0, L = -1, R = 1 }

  local function solve(get_key, sr, sc)
    local r, c = sr, sc
    local code = {}
    for _, line in ipairs(lines) do
      for i = 1, #line do
        local ch = line:sub(i, i)
        local nr, nc = r + dr[ch], c + dc[ch]
        if get_key(nr, nc) then
          r, c = nr, nc
        end
      end
      code[#code + 1] = get_key(r, c)
    end
    return table.concat(code)
  end

  local part1 = solve(key3, 2, 2)
  local part2 = solve(keyD, 3, 1)
  print(string.format('Part 1: %s', part1))
  print(string.format('Part 2: %s', part2))
end

return function(path)
  return day2(path)
end
